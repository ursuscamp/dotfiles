import type {
  CustomEntry,
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

const STATE_ENTRY = "plan-mode-state";
const MESSAGE_TYPE = "plan-mode-transition";
const STATUS_ID = "plan-mode";

const PLAN_INSTRUCTIONS = `[PI MODE CHANGED: PLAN]

Planning mode is now active. Inspect the project freely, but do not modify files or project state. Do not use the write or edit tools, and do not run mutating bash commands such as writes, deletes, installs, migrations, resets, commits, or other commands that change the project or its dependencies. Use read-only inspection commands to understand the codebase and develop or refine an implementation plan. Remain in planning mode until the user exits it with /plan or the plan-mode keyboard shortcut.`;

const EXECUTION_INSTRUCTIONS = `[PI MODE CHANGED: EXECUTION]

Planning mode is now inactive. Normal implementation and tool-use behavior may resume.`;

function setStatus(ctx: ExtensionContext, enabled: boolean): void {
  ctx.ui.setStatus(STATUS_ID, enabled ? "PLAN MODE (ctrl+shift+m to exit)" : undefined);
}

function transitionMessage(enabled: boolean): string {
  return enabled ? PLAN_INSTRUCTIONS : EXECUTION_INSTRUCTIONS;
}

export default function (pi: ExtensionAPI) {
  let planMode = false;

  const togglePlanMode = (ctx: ExtensionContext): void => {
    planMode = !planMode;

    pi.appendEntry(STATE_ENTRY, { enabled: planMode });
    pi.sendMessage(
      {
        customType: MESSAGE_TYPE,
        content: transitionMessage(planMode),
        display: true,
        details: { enabled: planMode },
      },
      { deliverAs: "nextTurn" },
    );

    setStatus(ctx, planMode);
    ctx.ui.notify(
      planMode ? "Plan mode enabled" : "Plan mode disabled",
      planMode ? "warning" : "info",
    );
  };

  pi.on("session_start", async (_event, ctx) => {
    const stateEntries = ctx.sessionManager
      .getBranch()
      .filter(
        (entry): entry is CustomEntry<{ enabled?: boolean }> =>
          entry.type === "custom" && entry.customType === STATE_ENTRY,
      );
    const latestState = stateEntries.at(-1);

    planMode = latestState?.data?.enabled === true;
    setStatus(ctx, planMode);
  });

  pi.on("session_compact", async (_event, ctx) => {
    if (!planMode) return;

    // Compaction may omit the earlier transition message from the active context.
    // Re-add the current mode once, rather than changing the system prompt on every turn.
    pi.sendMessage(
      {
        customType: MESSAGE_TYPE,
        content: PLAN_INSTRUCTIONS,
        display: true,
        details: { enabled: true, restoredAfterCompaction: true },
      },
      { deliverAs: "nextTurn" },
    );
    setStatus(ctx, true);
  });

  pi.registerCommand("plan", {
    description: "Toggle planning mode (prevents the model from making changes by instruction)",
    handler: async (_args, ctx) => {
      togglePlanMode(ctx);
    },
  });

  pi.registerShortcut("ctrl+shift+m", {
    description: "Toggle plan mode",
    handler: async (ctx) => {
      togglePlanMode(ctx);
    },
  });
}
