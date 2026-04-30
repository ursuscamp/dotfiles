/**
 * Codex usage status extension.
 *
 * Shows the current Codex ChatGPT subscription usage in pi's status bar when
 * the active model looks like a Codex model and the connected account is a
 * ChatGPT OAuth account.
 *
 * The extension talks to the local Codex app-server over stdio JSON-RPC and
 * reads `account/read` plus `account/rateLimits/read`.
 */

import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

interface SelectedModel {
  provider: string;
  id: string;
}

interface ExtensionContextLike {
  cwd: string;
  model?: SelectedModel;
  ui: {
    theme: {
      fg(color: "success" | "warning" | "error", text: string): string;
    };
    setStatus(key: string, text: string | undefined): void;
  };
}

interface AppServerAccount {
  type: "apiKey" | "chatgpt" | string;
  email?: string;
  planType?: string;
}

interface AccountReadResult {
  account: AppServerAccount | null;
  requiresOpenaiAuth: boolean;
}

interface RateLimitBucket {
  usedPercent: number;
  windowDurationMins?: number;
  resetsAt?: number;
}

interface RateLimitsReadResult {
  rateLimits?: {
    limitId?: string;
    limitName?: string | null;
    primary?: RateLimitBucket | null;
    secondary?: RateLimitBucket | null;
  };
  rateLimitsByLimitId?: Record<string, {
    limitId?: string;
    limitName?: string | null;
    primary?: RateLimitBucket | null;
    secondary?: RateLimitBucket | null;
  }>;
}

interface JsonRpcMessage {
  id?: number;
  method?: string;
  params?: unknown;
  result?: unknown;
  error?: { code: number; message: string; data?: unknown };
}

type NotificationHandler = (method: string, params: unknown) => void;

type PendingRequest = {
  resolve: (value: unknown) => void;
  reject: (error: Error) => void;
};

class CodexAppServerClient {
  private readonly bin: string;
  private readonly cwd: string;
  private child: ChildProcessWithoutNullStreams | undefined;
  private readonly pending = new Map<number, PendingRequest>();
  private readonly notificationHandlers = new Set<NotificationHandler>();
  private nextId = 1;
  private buffer = "";
  private initialized = false;
  private closed = false;
  private connectPromise: Promise<void> | undefined;

  public constructor(cwd: string) {
    this.cwd = cwd;
    this.bin = process.env.CODEX_BIN ?? "codex";
  }

  public onNotification(handler: NotificationHandler): () => void {
    this.notificationHandlers.add(handler);
    return () => this.notificationHandlers.delete(handler);
  }

  public async connect(): Promise<void> {
    if (this.connectPromise) {
      return this.connectPromise;
    }

    this.connectPromise = this.bootstrap().catch((error: unknown) => {
      this.connectPromise = undefined;
      throw error;
    });

    return this.connectPromise;
  }

  public async readAccount(): Promise<AccountReadResult> {
    await this.connect();
    return (await this.request("account/read", { refreshToken: false })) as AccountReadResult;
  }

  public async readRateLimits(): Promise<RateLimitsReadResult> {
    await this.connect();
    return (await this.request("account/rateLimits/read")) as RateLimitsReadResult;
  }

  public async close(): Promise<void> {
    this.closed = true;
    this.rejectAll(new Error("Codex app-server client was closed"));

    if (this.child) {
      this.child.stdout.off("data", this.handleStdout);
      this.child.stderr.off("data", this.handleStderr);
      this.child.off("exit", this.handleExit);
      this.child.off("error", this.handleError);
      this.child.kill();
      this.child = undefined;
    }
  }

  private async bootstrap(): Promise<void> {
    await this.startProcess();
    await this.request("initialize", {
      clientInfo: {
        name: "pi-codex-usage",
        title: "pi Codex Usage Status",
        version: "1.0.0",
      },
      capabilities: {
        experimentalApi: true,
        optOutNotificationMethods: ["thread/started", "item/agentMessage/delta"],
      },
    });

    await this.notify("initialized", {});
    this.initialized = true;
  }

  private async startProcess(): Promise<void> {
    if (this.child) {
      return;
    }

    const child = spawn(this.bin, ["app-server", "--listen", "stdio://"], {
      cwd: this.cwd,
      stdio: ["pipe", "pipe", "pipe"],
      env: process.env,
    });

    this.child = child;
    child.stdout.on("data", this.handleStdout);
    child.stderr.on("data", this.handleStderr);
    child.on("exit", this.handleExit);
    child.on("error", this.handleError);
  }

  private async request(method: string, params?: object): Promise<unknown> {
    if (!this.child) {
      throw new Error("Codex app-server is not running");
    }

    const id = this.nextId++;
    const payload = params === undefined ? { id, method } : { id, method, params };

    const result = await new Promise<unknown>((resolve, reject) => {
      this.pending.set(id, { resolve, reject });

      const ok = this.child?.stdin.write(`${JSON.stringify(payload)}\n`);
      if (ok === false) {
        // Backpressure is fine here; we just keep waiting for the response.
      }
    });

    return result;
  }

  private async notify(method: string, params: object): Promise<void> {
    if (!this.child) {
      throw new Error("Codex app-server is not running");
    }

    this.child.stdin.write(`${JSON.stringify({ method, params })}\n`);
  }

  private readonly handleStdout = (chunk: Buffer): void => {
    this.buffer += chunk.toString("utf8");

    while (true) {
      const newlineIndex = this.buffer.indexOf("\n");
      if (newlineIndex === -1) {
        break;
      }

      const rawLine = this.buffer.slice(0, newlineIndex).trim();
      this.buffer = this.buffer.slice(newlineIndex + 1);
      if (!rawLine) {
        continue;
      }

      let message: JsonRpcMessage;
      try {
        message = JSON.parse(rawLine) as JsonRpcMessage;
      } catch {
        continue;
      }

      this.handleMessage(message);
    }
  };

  private readonly handleStderr = (_chunk: Buffer): void => {
    // Keep stderr quiet; pi's own debug logging can capture this if needed.
  };

  private readonly handleExit = (code: number | null, signal: NodeJS.Signals | null): void => {
    if (this.closed) {
      return;
    }

    const suffix = code !== null ? ` with code ${code}` : signal ? ` (${signal})` : "";
    this.rejectAll(new Error(`Codex app-server exited unexpectedly${suffix}`));
    this.child = undefined;
    this.connectPromise = undefined;
    this.initialized = false;
  };

  private readonly handleError = (error: Error): void => {
    if (this.closed) {
      return;
    }

    this.rejectAll(error);
    this.child = undefined;
    this.connectPromise = undefined;
    this.initialized = false;
  };

  private handleMessage(message: JsonRpcMessage): void {
    if (typeof message.id === "number") {
      const pending = this.pending.get(message.id);
      if (!pending) {
        return;
      }

      this.pending.delete(message.id);
      if (message.error) {
        pending.reject(new Error(message.error.message));
        return;
      }

      pending.resolve(message.result);
      return;
    }

    if (typeof message.method === "string") {
      for (const handler of this.notificationHandlers) {
        handler(message.method, message.params);
      }
    }
  }

  private rejectAll(error: Error): void {
    for (const [, pending] of this.pending) {
      pending.reject(error);
    }
    this.pending.clear();
  }
}

type RateLimitDisplay = {
  key: string;
  label: "hourly" | "weekly" | string;
  usedPercent: number;
  windowDurationMins?: number;
  resetsAt?: number;
};

function remainingPercent(usedPercent: number): number {
  return Math.max(0, 100 - Math.round(usedPercent));
}

function toneForRemaining(remaining: number): "success" | "warning" | "error" {
  if (remaining <= 20) {
    return "error";
  }

  if (remaining <= 50) {
    return "warning";
  }

  return "success";
}

function formatDuration(unixSeconds: number | undefined): string | undefined {
  if (typeof unixSeconds !== "number") {
    return undefined;
  }

  const remainingSeconds = Math.max(0, unixSeconds - Math.floor(Date.now() / 1000));
  if (remainingSeconds <= 0) {
    return "now";
  }

  const minutes = Math.ceil(remainingSeconds / 60);
  if (minutes < 60) {
    return `${minutes}m`;
  }

  const hours = Math.ceil(minutes / 60);
  if (hours < 24) {
    return `${hours}h`;
  }

  const days = Math.ceil(hours / 24);
  return `${days}d`;
}

function labelForBucket(bucket: RateLimitBucket, fallbackKey: string): string {
  if (typeof bucket.windowDurationMins === "number") {
    if (bucket.windowDurationMins >= 240 && bucket.windowDurationMins <= 360) {
      return "5h";
    }

    if (bucket.windowDurationMins >= 6 * 24 * 60 && bucket.windowDurationMins <= 8 * 24 * 60) {
      return "weekly";
    }
  }

  const fallback = fallbackKey.toLowerCase();
  if (fallback.includes("5h") || fallback.includes("five")) {
    return "5h";
  }
  if (fallback.includes("week")) {
    return "weekly";
  }
  return fallbackKey;
}

function collectRateLimits(rateLimits: RateLimitsReadResult): RateLimitDisplay[] {
  const collected: RateLimitDisplay[] = [];
  const seen = new Set<string>();

  const addBucket = (bucket: RateLimitBucket | null | undefined, key: string): void => {
    if (!bucket) {
      return;
    }

    const label = labelForBucket(bucket, key);
    const dedupeKey = `${label}:${bucket.usedPercent}:${bucket.windowDurationMins ?? ""}:${bucket.resetsAt ?? ""}`;
    if (seen.has(dedupeKey)) {
      return;
    }

    seen.add(dedupeKey);
    collected.push({
      key,
      label,
      usedPercent: bucket.usedPercent,
      windowDurationMins: bucket.windowDurationMins,
      resetsAt: bucket.resetsAt,
    });
  };

  if (rateLimits.rateLimits?.primary || rateLimits.rateLimits?.secondary) {
    addBucket(rateLimits.rateLimits.primary, rateLimits.rateLimits.limitId ? `${rateLimits.rateLimits.limitId}:primary` : "primary");
    addBucket(rateLimits.rateLimits.secondary, rateLimits.rateLimits.limitId ? `${rateLimits.rateLimits.limitId}:secondary` : "secondary");
  }

  for (const [limitId, info] of Object.entries(rateLimits.rateLimitsByLimitId ?? {})) {
    addBucket(info.primary ?? null, `${limitId}:primary`);
    addBucket(info.secondary ?? null, `${limitId}:secondary`);
  }

  return collected;
}

function pickPreferredBuckets(rateLimits: RateLimitsReadResult): RateLimitDisplay[] {
  const all = collectRateLimits(rateLimits);
  const fiveHour = all.find((bucket) => bucket.label === "5h");
  const weekly = all.find((bucket) => bucket.label === "weekly");

  const chosen: RateLimitDisplay[] = [];
  if (fiveHour) {
    chosen.push(fiveHour);
  }
  if (weekly && weekly.key !== fiveHour?.key) {
    chosen.push(weekly);
  }

  if (chosen.length > 0) {
    return chosen;
  }

  return all.slice(0, 2);
}

function buildStatusText(ctx: ExtensionContextLike, rateLimits: RateLimitsReadResult): string | undefined {
  const buckets = pickPreferredBuckets(rateLimits);
  if (buckets.length === 0) {
    return undefined;
  }

  const parts = buckets.map((bucket) => {
    const remaining = remainingPercent(bucket.usedPercent);
    const tone = toneForRemaining(remaining);
    const label = bucket.label === "5h" ? "5h" : bucket.label === "weekly" ? "1w" : bucket.label;
    const remainingText = ctx.ui.theme.fg(tone, `${remaining}%`);
    const labelText = ctx.ui.theme.fg("dim", label);
    const resetText = formatDuration(bucket.resetsAt);
    const resetSegment = resetText ? ctx.ui.theme.fg("dim", ` resets ${resetText}`) : "";
    return `${labelText} ${remainingText} left${resetSegment}`;
  });

  return ctx.ui.theme.fg("accent", `Codex ${parts.join(ctx.ui.theme.fg("dim", " · "))}`);
}

export default function (pi: ExtensionAPI) {
  const statusKey = "codex-usage";
  const pollIntervalMs = 60_000;
  let client: CodexAppServerClient | undefined;
  let pollTimer: ReturnType<typeof setInterval> | undefined;
  let refreshInFlight = false;
  let currentStatus = "";
  let currentAccountIsChatGPT = false;
  let currentCwd = "";

  function clearStatus(ctx: ExtensionContextLike): void {
    currentStatus = "";
    currentAccountIsChatGPT = false;
    ctx.ui.setStatus(statusKey, undefined);
  }

  function setStatus(ctx: ExtensionContextLike, rateLimits: RateLimitsReadResult): void {
    const text = buildStatusText(ctx, rateLimits);
    if (!text || text === currentStatus) {
      return;
    }

    currentStatus = text;
    ctx.ui.setStatus(statusKey, text);
  }

  async function closeClient(): Promise<void> {
    if (client) {
      await client.close();
      client = undefined;
    }

    currentAccountIsChatGPT = false;
    currentStatus = "";
  }

  function stopPolling(): void {
    if (pollTimer) {
      clearInterval(pollTimer);
      pollTimer = undefined;
    }
  }

  async function refresh(ctx: ExtensionContextLike): Promise<void> {
    currentCwd = ctx.cwd;

    if (refreshInFlight) {
      return;
    }

    refreshInFlight = true;
    try {
      ensurePolling(ctx);

      if (!client) {
        client = new CodexAppServerClient(currentCwd);
        client.onNotification((method, params) => {
          if (method !== "account/rateLimits/updated" || !currentAccountIsChatGPT) {
            return;
          }

          const rateLimits = params as RateLimitsReadResult | undefined;
          if (rateLimits) {
            setStatus(ctx, rateLimits);
          }
        });
      }

      await client.connect();
      const account = await client.readAccount();
      currentAccountIsChatGPT = account.account?.type === "chatgpt";

      if (!currentAccountIsChatGPT) {
        clearStatus(ctx);
        return;
      }

      const rateLimits = await client.readRateLimits();
      setStatus(ctx, rateLimits);
    } catch {
      await closeClient();
      clearStatus(ctx);
    } finally {
      refreshInFlight = false;
    }
  }

  function ensurePolling(ctx: ExtensionContextLike): void {
    if (pollTimer) {
      return;
    }

    pollTimer = setInterval(() => {
      void refresh(ctx);
    }, pollIntervalMs);
  }

  pi.on("session_start", async (_event, ctx) => {
    currentCwd = ctx.cwd;
    ensurePolling(ctx as ExtensionContextLike);
    await refresh(ctx as ExtensionContextLike);
  });

  pi.on("model_select", async (_event, ctx) => {
    await refresh(ctx as ExtensionContextLike);
  });

  pi.on("agent_end", async (_event, ctx) => {
    await refresh(ctx as ExtensionContextLike);
  });

  pi.on("session_shutdown", async () => {
    stopPolling();
    await closeClient();
  });
}
