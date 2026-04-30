import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

function sanitizeStatusText(text: string): string {
  return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

function formatTokens(count: number): string {
  if (count < 1000) return count.toString();
  if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
  if (count < 1000000) return `${Math.round(count / 1000)}k`;
  if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
  return `${Math.round(count / 1000000)}M`;
}

function installFooter(ctx: ExtensionContext) {
  if (!ctx.hasUI) return;

  ctx.ui.setFooter((tui, theme, footerData) => {
    const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

    return {
      dispose: unsubscribe,
      invalidate() {},
      render(width: number): string[] {
        let totalInput = 0;
        let totalOutput = 0;
        let totalCacheRead = 0;
        let totalCacheWrite = 0;
        let totalCost = 0;

        for (const entry of ctx.sessionManager.getEntries()) {
          if (entry.type === "message" && entry.message.role === "assistant") {
            const message = entry.message as AssistantMessage;
            totalInput += message.usage.input;
            totalOutput += message.usage.output;
            totalCacheRead += message.usage.cacheRead;
            totalCacheWrite += message.usage.cacheWrite;
            totalCost += message.usage.cost.total;
          }
        }

        const contextUsage = ctx.getContextUsage();
        const contextWindow = contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
        const contextPercentValue = contextUsage?.percent ?? 0;
        const contextPercent = typeof contextUsage?.percent === "number" ? contextPercentValue.toFixed(1) : "?";

        let pwd = ctx.sessionManager.getCwd();
        const home = process.env.HOME || process.env.USERPROFILE;
        if (home && pwd.startsWith(home)) pwd = `~${pwd.slice(home.length)}`;

        const branch = footerData.getGitBranch();
        if (branch) pwd = `${pwd} (${branch})`;

        const sessionName = ctx.sessionManager.getSessionName();
        if (sessionName) pwd = `${pwd} • ${sessionName}`;

        const statsParts: string[] = [];
        if (totalInput) statsParts.push(`↑${formatTokens(totalInput)}`);
        if (totalOutput) statsParts.push(`↓${formatTokens(totalOutput)}`);
        if (totalCacheRead) statsParts.push(`R${formatTokens(totalCacheRead)}`);
        if (totalCacheWrite) statsParts.push(`W${formatTokens(totalCacheWrite)}`);

        const usingSubscription = ctx.model ? ctx.modelRegistry.isUsingOAuth(ctx.model as any) : false;
        if (totalCost || usingSubscription) statsParts.push(`$${totalCost.toFixed(3)}${usingSubscription ? " (sub)" : ""}`);

        const contextDisplay = contextPercent === "?" ? `?/${formatTokens(contextWindow)}` : `${contextPercent}%/${formatTokens(contextWindow)}`;
        statsParts.push(
          contextPercentValue > 90
            ? theme.fg("error", contextDisplay)
            : contextPercentValue > 70
              ? theme.fg("warning", contextDisplay)
              : contextDisplay,
        );

        let statsLeft = statsParts.join(" ");
        let statsLeftWidth = visibleWidth(statsLeft);
        if (statsLeftWidth > width) {
          statsLeft = truncateToWidth(statsLeft, width, "...");
          statsLeftWidth = visibleWidth(statsLeft);
        }

        const modelName = ctx.model?.id || "no-model";
        const rightSide = footerData.getAvailableProviderCount() > 1 && ctx.model ? `(${ctx.model.provider}) ${modelName}` : modelName;
        const rightSideWidth = visibleWidth(rightSide);
        const padding = " ".repeat(Math.max(2, width - statsLeftWidth - rightSideWidth));

        const lines = [
          truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "...")),
          theme.fg("dim", statsLeft) + theme.fg("dim", padding + truncateToWidth(rightSide, Math.max(0, width - statsLeftWidth - 2), "")),
        ];

        const statuses = Array.from(footerData.getExtensionStatuses().entries())
          .sort(([a], [b]) => a.localeCompare(b))
          .map(([, text]) => sanitizeStatusText(text))
          .filter(Boolean);

        if (statuses.length > 0) {
          lines.push(truncateToWidth(statuses.join(theme.fg("dim", " │ ")), width, theme.fg("dim", "...")));
        }

        return lines;
      },
    };
  });
}

export default function(pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => installFooter(ctx));
  pi.on("session_tree", async (_event, ctx) => installFooter(ctx));
}
