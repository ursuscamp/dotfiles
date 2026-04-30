import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";

// A small, self-contained plan-mode extension for pi.
// Place in ~/.pi/agent/extensions/plan-mode.ts and run /reload.

type Mode = "normal" | "planning" | "executing";

type PlanStep = {
	step: number;
	text: string;
	completed: boolean;
};

const PLANNING_TOOLS = ["read", "grep", "find", "ls", "bash"];
const DEFAULT_NORMAL_TOOLS = ["read", "grep", "find", "ls", "bash", "edit", "write"];
const STATE_ENTRY = "plan-mode-state";
const PLAN_CONTEXT_ENTRY = "plan-mode-context";
const EXECUTE_CONTEXT_ENTRY = "plan-mode-execute";
const PLAN_DONE_TOOL = "plan_done";

function firstWord(command: string): string {
	return command.trim().split(/\s+/)[0]?.replace(/^env$/, "") ?? "";
}

function splitCommandChain(command: string): string[] {
	return command
		.replace(/\\\n/g, " ")
		.split(/\s*(?:&&|\|\||;|\n)\s*/g)
		.map((part) => part.trim())
		.filter(Boolean);
}

function stripHarmlessPrefixes(command: string): string {
	let cmd = command.trim();
	cmd = cmd.replace(/^\s*(?:time|command|builtin|noglob)\s+/, "");
	cmd = cmd.replace(/^\s*(?:[A-Za-z_][A-Za-z0-9_]*=[^\s]+\s+)+/, "");
	return cmd.trim();
}

function isSafeGitCommand(args: string[]): boolean {
	const subcommand = args[1] ?? "";
	return ["status", "diff", "log", "show", "branch", "rev-parse", "ls-files", "grep", "describe", "remote"].includes(
		subcommand,
	);
}

function isSafePackageCommand(cmd: string, args: string[]): boolean {
	const subcommand = args[1] ?? "";
	if (["npm", "yarn", "pnpm", "bun"].includes(cmd)) {
		return ["list", "ls", "outdated", "info", "view", "why", "audit"].includes(subcommand);
	}
	if (["pip", "pip3"].includes(cmd)) return ["list", "show", "freeze", "check"].includes(subcommand);
	return false;
}

function isSafeCommand(command: string): boolean {
	const blockedPattern = /(^|\s)(sudo|su|rm|rmdir|mv|cp|mkdir|touch|chmod|chown|ln|tee|truncate|dd|kill|pkill|killall|reboot|shutdown|halt|vim|vi|nano|code|emacs)($|\s)/;
	const redirectPattern = /(^|[^<])>(?!>?)|>>|\b(?:edit|write)\b/i;
	if (blockedPattern.test(command) || redirectPattern.test(command)) return false;

	for (const rawPart of splitCommandChain(command)) {
		const part = stripHarmlessPrefixes(rawPart);
		const args = part.split(/\s+/).filter(Boolean);
		const cmd = firstWord(part);
		if (!cmd) continue;

		const safeCommands = new Set([
			"ls",
			"pwd",
			"cat",
			"head",
			"tail",
			"less",
			"more",
			"grep",
			"egrep",
			"fgrep",
			"rg",
			"find",
			"fd",
			"tree",
			"wc",
			"sort",
			"uniq",
			"cut",
			"awk",
			"sed",
			"jq",
			"python",
			"python3",
			"node",
			"uname",
			"whoami",
			"date",
			"uptime",
			"which",
			"type",
		]);

		if (cmd === "git") {
			if (!isSafeGitCommand(args)) return false;
			continue;
		}
		if (["npm", "yarn", "pnpm", "bun", "pip", "pip3"].includes(cmd)) {
			if (!isSafePackageCommand(cmd, args)) return false;
			continue;
		}
		if (!safeCommands.has(cmd)) return false;
	}
	return true;
}

function extractText(message: any): string {
	if (!message) return "";
	const content = message.content;
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	return content
		.filter((block: any) => block?.type === "text" && typeof block.text === "string")
		.map((block: any) => block.text)
		.join("\n");
}

function isAssistantMessage(message: any): boolean {
	return message?.role === "assistant";
}

function extractPlanSteps(text: string): PlanStep[] {
	const planStart = text.search(/^\s*(?:#{1,6}\s*)?Plan\s*:/im);
	if (planStart < 0) return [];

	const planText = text.slice(planStart);
	const steps: PlanStep[] = [];
	const re = /^\s*(\d+)[.)]\s+(.+?)(?=\n\s*\d+[.)]\s+|\n\s*(?:#{1,6}\s*)?\w[^\n]*:\s*$|$)/gms;
	let match: RegExpExecArray | null;
	while ((match = re.exec(planText))) {
		const step = Number(match[1]);
		const itemText = match[2].replace(/\s+/g, " ").trim();
		if (Number.isFinite(step) && itemText) steps.push({ step, text: itemText, completed: false });
	}
	return steps;
}

export default function planMode(pi: ExtensionAPI): void {
	let mode: Mode = "normal";
	let steps: PlanStep[] = [];
	let normalTools: string[] = [];

	pi.registerFlag("plan", {
		description: "Start in plan mode (read-only exploration)",
		type: "boolean",
		default: false,
	});

	function activeNormalTools(): string[] {
		return normalTools.length > 0 ? normalTools : DEFAULT_NORMAL_TOOLS;
	}

	function executionTools(): string[] {
		return Array.from(new Set([...activeNormalTools(), PLAN_DONE_TOOL]));
	}

	function persist(): void {
		pi.appendEntry(STATE_ENTRY, { mode, steps });
	}

	function markStepDone(stepNumber: number): boolean {
		const step = steps.find((s) => s.step === stepNumber);
		if (!step || step.completed) return false;
		step.completed = true;
		return true;
	}

	function updateUi(ctx: ExtensionContext): void {
		if (mode === "planning") {
			ctx.ui.setStatus("plan-mode", ctx.ui.theme.fg("warning", "⏸ plan"));
		} else if (mode === "executing" && steps.length > 0) {
			const completed = steps.filter((s) => s.completed).length;
			ctx.ui.setStatus("plan-mode", ctx.ui.theme.fg("accent", `📋 ${completed}/${steps.length}`));
		} else {
			ctx.ui.setStatus("plan-mode", undefined);
		}

		if ((mode === "planning" || mode === "executing") && steps.length > 0) {
			ctx.ui.setWidget(
				"plan-mode-steps",
				steps.map((s) => {
					const box = s.completed ? ctx.ui.theme.fg("success", "☑ ") : ctx.ui.theme.fg("muted", "☐ ");
					const text = s.completed ? ctx.ui.theme.fg("muted", ctx.ui.theme.strikethrough(s.text)) : s.text;
					return `${box}${s.step}. ${text}`;
				}),
			);
		} else {
			ctx.ui.setWidget("plan-mode-steps", undefined);
		}
	}

	function enterPlanning(ctx: ExtensionContext): void {
		if (mode === "normal") normalTools = pi.getActiveTools();
		mode = "planning";
		steps = [];
		pi.setActiveTools(PLANNING_TOOLS);
		ctx.ui.notify(`Plan mode enabled. Read-only tools: ${PLANNING_TOOLS.join(", ")}`, "info");
		updateUi(ctx);
		persist();
	}

	function enterNormal(ctx: ExtensionContext): void {
		mode = "normal";
		steps = [];
		pi.setActiveTools(activeNormalTools());
		ctx.ui.notify("Plan mode disabled. Normal tools restored.", "info");
		updateUi(ctx);
		persist();
	}

	function enterExecuting(ctx: ExtensionContext): void {
		mode = "executing";
		pi.setActiveTools(executionTools());
		ctx.ui.notify("Executing approved plan. The agent should call plan_done after each completed step.", "info");
		updateUi(ctx);
		persist();
		const first = steps.find((s) => !s.completed);
		pi.sendMessage(
			{
				customType: EXECUTE_CONTEXT_ENTRY,
				content: first ? `Execute the approved plan. Start with step ${first.step}: ${first.text}` : "Execute the approved plan.",
				display: true,
			},
			{ triggerTurn: true },
		);
	}

	pi.registerTool({
		name: PLAN_DONE_TOOL,
		label: "Plan Done",
		description: "Mark a plan step as completed. Use this immediately after finishing each approved plan step.",
		promptSnippet: "Mark an approved plan step complete during plan execution",
		promptGuidelines: [
			"When executing an approved plan, call plan_done immediately after each step is complete so the UI task list and footer counter update.",
		],
		parameters: Type.Object({
			step: Type.Number({ description: "The plan step number that was completed" }),
			notes: Type.Optional(Type.String({ description: "Brief note about what was completed" })),
		}),
		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			if (mode !== "executing") {
				return {
					isError: true,
					content: [{ type: "text", text: "plan_done can only be used while executing a plan." }],
				};
			}
			const changed = markStepDone(params.step);
			updateUi(ctx);
			persist();
			const completed = steps.filter((s) => s.completed).length;
			return {
				content: [
					{
						type: "text",
						text: changed
							? `Marked plan step ${params.step} complete (${completed}/${steps.length}).`
							: `Plan step ${params.step} was already complete or does not exist (${completed}/${steps.length}).`,
					},
				],
				details: { step: params.step, changed, completed, total: steps.length, notes: params.notes },
			};
		},
	});

	pi.registerCommand("plan", {
		description: "Plan mode: /plan [on|off|execute|status]",
		handler: async (args, ctx) => {
			const arg = (args ?? "").trim().toLowerCase();
			if (arg === "on") return enterPlanning(ctx);
			if (arg === "off" || arg === "normal") return enterNormal(ctx);
			if (arg === "execute") {
				if (steps.length === 0) ctx.ui.notify("No extracted plan yet. Ask for a numbered Plan: first.", "warning");
				else enterExecuting(ctx);
				return;
			}
			if (arg === "status") {
				const list = steps.length ? steps.map((s) => `${s.completed ? "✓" : "○"} ${s.step}. ${s.text}`).join("\n") : "No plan steps.";
				ctx.ui.notify(`Plan mode: ${mode}\n${list}`, "info");
				return;
			}
			return mode === "normal" ? enterPlanning(ctx) : enterNormal(ctx);
		},
	});

	pi.registerShortcut("ctrl+alt+p", {
		description: "Toggle plan mode",
		handler: async (ctx) => (mode === "normal" ? enterPlanning(ctx) : enterNormal(ctx)),
	});

	pi.on("tool_call", async (event) => {
		if (mode !== "planning") return;
		if (event.toolName !== "bash") return;
		const command = String((event.input as any).command ?? "");
		if (!isSafeCommand(command)) {
			return { block: true, reason: `Plan mode blocked non-read-only bash command:\n${command}` };
		}
	});

	pi.on("before_agent_start", async () => {
		if (mode === "planning") {
			return {
				message: {
					customType: PLAN_CONTEXT_ENTRY,
					display: false,
					content: `[PLAN MODE ACTIVE]
You are in read-only planning mode.
- Inspect files and gather context, but do not modify files.
- Available tools are read-only; bash is restricted to safe inspection commands.
- If requirements are unclear, ask concise clarifying questions.
- End with a numbered plan under the exact heading "Plan:".
- Do not execute the plan yet.`,
				},
			};
		}

		if (mode === "executing" && steps.length > 0) {
			const remaining = steps.filter((s) => !s.completed).map((s) => `${s.step}. ${s.text}`).join("\n");
			return {
				message: {
					customType: EXECUTE_CONTEXT_ENTRY,
					display: false,
					content: `[EXECUTING APPROVED PLAN]
Follow the remaining steps in order:
${remaining}

After completing step N, call the plan_done tool with { step: N }.`,
				},
			};
		}
	});


	pi.on("agent_end", async (event, ctx) => {
		if (mode === "executing" && steps.length > 0 && steps.every((s) => s.completed)) {
			pi.sendMessage({ customType: "plan-mode-complete", display: true, content: "✅ Plan complete." }, { triggerTurn: false });
			mode = "normal";
			steps = [];
			pi.setActiveTools(activeNormalTools());
			updateUi(ctx);
			persist();
			return;
		}

		if (mode !== "planning") return;
		const lastAssistant = [...(event as any).messages].reverse().find(isAssistantMessage);
		const extracted = extractPlanSteps(extractText(lastAssistant));
		if (extracted.length > 0) {
			steps = extracted;
			updateUi(ctx);
			persist();
		}
		if (!ctx.hasUI || steps.length === 0) return;

		const choice = await ctx.ui.select("Plan created. What next?", [
			"Execute the plan",
			"Refine the plan",
			"Stay in plan mode",
			"Exit plan mode",
		]);
		if (choice === "Execute the plan") enterExecuting(ctx);
		else if (choice === "Exit plan mode") enterNormal(ctx);
		else if (choice === "Refine the plan") {
			const refinement = await ctx.ui.editor("How should the plan be refined?", "");
			if (refinement?.trim()) pi.sendUserMessage(refinement.trim());
		}
	});

	pi.on("session_start", async (_event, ctx) => {
		normalTools = pi.getActiveTools();
		if (pi.getFlag("plan") === true) mode = "planning";

		const latest = ctx.sessionManager
			.getEntries()
			.filter((e: any) => e.type === "custom" && e.customType === STATE_ENTRY)
			.pop() as any;
		if (latest?.data) {
			mode = latest.data.mode ?? mode;
			steps = Array.isArray(latest.data.steps) ? latest.data.steps : steps;
		}

		if (mode === "planning") pi.setActiveTools(PLANNING_TOOLS);
		else if (mode === "executing") pi.setActiveTools(executionTools());
		else pi.setActiveTools(activeNormalTools());
		updateUi(ctx);
	});
}
