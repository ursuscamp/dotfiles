import { Type } from "typebox";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MCP_URL =
  process.env.EXA_MCP_URL ??
  "https://mcp.exa.ai/mcp?tools=web_search_exa,web_fetch_exa";
const PROTOCOL_VERSION = "2024-11-05";

type JsonRpcResponse = {
  result?: {
    content?: Array<{ type: string; text?: string; [key: string]: unknown }>;
    isError?: boolean;
  };
  error?: { code: number; message: string; data?: unknown };
};

let nextRequestId = 1;
let sessionId: string | undefined;
let initialization: Promise<void> | undefined;

async function readMcpResponse(response: Response): Promise<JsonRpcResponse> {
  const body = await response.text();
  if (!body) return {};

  if (response.headers.get("content-type")?.includes("text/event-stream")) {
    const data = body
      .split("\n")
      .filter((line) => line.startsWith("data:"))
      .map((line) => line.slice(5).trim())
      .filter(Boolean)
      .at(-1);
    return data ? (JSON.parse(data) as JsonRpcResponse) : {};
  }

  return JSON.parse(body) as JsonRpcResponse;
}

async function mcpRequest(
  method: string,
  params: Record<string, unknown>,
  signal?: AbortSignal,
): Promise<JsonRpcResponse> {
  const response = await fetch(MCP_URL, {
    method: "POST",
    signal,
    headers: {
      Accept: "application/json, text/event-stream",
      "Content-Type": "application/json",
      ...(sessionId ? { "Mcp-Session-Id": sessionId } : {}),
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: nextRequestId++,
      method,
      params,
    }),
  });

  const result = await readMcpResponse(response);
  if (!response.ok) {
    throw new Error(
      `Exa MCP request failed (${response.status}): ${
        result.error?.message ?? response.statusText
      }`,
    );
  }
  if (result.error) throw new Error(result.error.message);

  sessionId ??= response.headers.get("mcp-session-id") ?? undefined;
  return result;
}

async function ensureInitialized(): Promise<void> {
  if (!initialization) {
    initialization = (async () => {
      await mcpRequest("initialize", {
        protocolVersion: PROTOCOL_VERSION,
        capabilities: {},
        clientInfo: { name: "pi-exa-web", version: "1.0.0" },
      });
      await fetch(MCP_URL, {
        method: "POST",
        headers: {
          Accept: "application/json, text/event-stream",
          "Content-Type": "application/json",
          ...(sessionId ? { "Mcp-Session-Id": sessionId } : {}),
        },
        body: JSON.stringify({
          jsonrpc: "2.0",
          method: "notifications/initialized",
          params: {},
        }),
      });
    })().catch((error) => {
      initialization = undefined;
      throw error;
    });
  }
  await initialization;
}

async function callExaTool(
  name: "web_search_exa" | "web_fetch_exa",
  arguments_: Record<string, unknown>,
  signal?: AbortSignal,
) {
  await ensureInitialized();
  const response = await mcpRequest(
    "tools/call",
    { name, arguments: arguments_ },
    signal,
  );
  const result = response.result;
  if (!result) throw new Error("Exa MCP returned an empty response");
  if (result.isError) throw new Error(result.content?.[0]?.text ?? "Exa MCP tool failed");

  return {
    content: result.content ?? [],
    details: { provider: "exa", tool: name },
  };
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description: "Search the web with Exa and return relevant results.",
    parameters: Type.Object({
      query: Type.String({ description: "The web search query" }),
    }),
    async execute(_toolCallId, params, signal) {
      return callExaTool("web_search_exa", params, signal);
    },
  });

  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description: "Fetch a webpage with Exa and return its content as markdown.",
    parameters: Type.Object({
      urls: Type.Array(Type.String(), {
        description: "URLs of the webpages to fetch. Multiple URLs may be fetched in one call.",
      }),
      maxCharacters: Type.Optional(
        Type.Number({
          minimum: 1,
          description: "Maximum characters to extract per page (default: 3000)",
        }),
      ),
    }),
    async execute(_toolCallId, params, signal) {
      return callExaTool("web_fetch_exa", params, signal);
    },
  });
}
