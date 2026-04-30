import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";

const SAVE_TYPE = "mutating-bash-permission-state";
const STATUS_ID = "bash-permissions";

interface SaveState {
  enabled: boolean;
}

const mutatingCommandPatterns: RegExp[] = [
  /\b(?:rm|mv|cp|mkdir|rmdir|touch|ln|chmod|chown|truncate)\b/i,
  /\b(?:git\s+(?:add|commit|push|merge|rebase|reset|checkout|switch|stash|pull|tag|branch|fetch)|npm\s+(?:install|add|remove|uninstall|ci|update|pack|publish)|pnpm\s+(?:add|install|remove|update|publish|dlx)|yarn\s+(?:add|install|remove|upgrade|publish)|bun\s+(?:add|install|remove|update|publish)|pip(?:3)?\s+install|cargo\s+install|go\s+install|brew\s+install|apt(?:-get)?\s+(?:install|remove|purge|upgrade|dist-upgrade)|dnf\s+(?:install|remove|upgrade)|yum\s+(?:install|remove|update)|pacman\s+-(?:S|R|U))\b/i,
  /\b(?:sed\s+-i|perl\s+-i|tee\s+-a?|dd\b|install\b)\b/i,
  />\s*(?!&?\s*\/dev\/null\b)/,
  />>\s*(?!\s*\/dev\/null\b)/,
];

function isMutatingBash(command: string): boolean {
  const segments = command
    .split(/(?:\n|&&|\|\||;)/g)
    .map((part) => part.trim())
    .filter(Boolean);

  for (const segment of segments) {
    if (mutatingCommandPatterns.some((pattern) => pattern.test(segment))) {
      return true;
    }
  }

  return false;
}

function restoreState(ctx: ExtensionContext): boolean {
  let enabled = true;

  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type !== "custom" || entry.customType !== SAVE_TYPE) continue;
    const data = entry.data as SaveState | undefined;
    if (typeof data?.enabled === "boolean") {
      enabled = data.enabled;
    }
  }

  return enabled;
}

export default function(pi: ExtensionAPI) {
  let enabled = true;

  function syncStatus(ctx?: ExtensionContext) {
    if (!ctx?.hasUI) return;
    const label = ctx.ui.theme.fg("dim", "bash perms: ");
    const value = ctx.ui.theme.fg(enabled ? "success" : "error", enabled ? "on" : "off");
    ctx.ui.setStatus(STATUS_ID, `${label}${value}`);
  }

  function persist() {
    pi.appendEntry<SaveState>(SAVE_TYPE, { enabled });
  }

  function setEnabled(nextEnabled: boolean, ctx?: ExtensionContext) {
    enabled = nextEnabled;
    syncStatus(ctx);
    persist();
  }

  pi.registerCommand("bash", {
    description: "Toggle permission prompts for mutating bash commands",
    handler: async (args, ctx) => {
      const value = args.trim().toLowerCase();

      if (value === "" || value === "toggle") {
        setEnabled(!enabled, ctx);
        ctx.ui.notify(`Mutating bash permission prompts are now ${enabled ? "on" : "off"}.`, "info");
        return;
      }

      if (value === "status") {
        ctx.ui.notify(`Mutating bash permission prompts are ${enabled ? "on" : "off"}.`, "info");
        return;
      }

      if (["on", "enable", "enabled"].includes(value)) {
        setEnabled(true, ctx);
        ctx.ui.notify("Mutating bash permission prompts enabled for this session.", "info");
        return;
      }

      if (["off", "disable", "disabled"].includes(value)) {
        setEnabled(false, ctx);
        ctx.ui.notify("Mutating bash permission prompts disabled for this session.", "info");
        return;
      }

      ctx.ui.notify('Usage: /bash [on|off|toggle|status]', "info");
    },
  });

  pi.on("session_start", async (_event, ctx) => {
    enabled = restoreState(ctx);
    syncStatus(ctx);
  });

  pi.on("session_tree", async (_event, ctx) => {
    enabled = restoreState(ctx);
    syncStatus(ctx);
  });

  pi.on("tool_call", async (event, ctx) => {
    if (!enabled) return;
    if (!isToolCallEventType("bash", event)) return;

    const command = String(event.input.command ?? "");
    if (!isMutatingBash(command)) return;

    if (!ctx.hasUI) {
      return { block: true, reason: "Mutating bash commands require confirmation (no UI available)" };
    }

    const choice = await ctx.ui.select(
      `Allow this mutating bash command?\n\n${command}`,
      ["Allow once", "Block", "Disable prompts for this session"],
    );

    if (choice === "Disable prompts for this session") {
      setEnabled(false, ctx);
      ctx.ui.notify("Mutating bash permission prompts disabled for this session.", "info");
      return;
    }

    if (choice !== "Allow once") {
      return { block: true, reason: "Blocked by user" };
    }
  });
}
