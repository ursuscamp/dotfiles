/**
 * Global Vim-style prompt editor for pi.
 *
 * Install by placing this file in ~/.pi/agent/extensions/ and then run /reload.
 * The editor starts in insert mode and provides a modal normal mode with
 * movement keys, operators, counts, search repeats, and line-wise paste.
 */

import { CustomEditor, type ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { matchesKey, truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

type Mode = "insert" | "normal";
type PendingPrefix = "g" | "f" | "F" | "t" | "T" | "r";
type PendingTextObjectPrefix = "a" | "i";
type PendingOperator = "d" | "c" | "y";
type MotionKind =
	| "h"
	| "j"
	| "k"
	| "l"
	| "w"
	| "b"
	| "e"
	| "W"
	| "B"
	| "E"
	| "0"
	| "^"
	| "$"
	| "G"
	| "gg"
	| "H"
	| "M"
	| "L"
	| "f"
	| "F"
	| "t"
	| "T"
	| ";"
	| ",";

type CursorPos = { line: number; col: number };

type SearchState = {
	kind: "f" | "F" | "t" | "T";
	char: string;
	count: number;
};

interface EditorRuntime {
	state: {
		lines: string[];
		cursorLine: number;
		cursorCol: number;
	};
	lastAction: string | null;
	jumpMode: string | null;
	preferredVisualCol: number | null;
	snappedFromCursorCol: number | null;
	historyIndex: number;
	tui: { requestRender(): void };
	onChange?: (text: string) => void;
	cancelAutocomplete?: () => void;
	pushUndoSnapshot?: () => void;
	setCursorCol: (col: number) => void;
	moveCursor: (deltaLine: number, deltaCol: number) => void;
	moveWordBackwards: () => void;
	moveWordForwards: () => void;
	moveToLineStart: () => void;
	moveToLineEnd: () => void;
	deleteToStartOfLine: () => void;
	deleteToEndOfLine: () => void;
	deleteWordBackwards: () => void;
	deleteWordForward: () => void;
	handleBackspace: () => void;
	handleForwardDelete: () => void;
	yank: () => void;
	yankPop: () => void;
	insertYankedText: (text: string) => void;
	undo: () => void;
	killRing: {
		push(text: string, opts: { prepend: boolean; accumulate?: boolean }): void;
		peek(): string | undefined;
		length: number;
		rotate(): void;
	};
	getText: () => string;
};

function isPrintable(data: string): boolean {
	return data.length === 1 && data.charCodeAt(0) >= 32;
}

function isWhitespaceChar(ch: string): boolean {
	return /\s/.test(ch);
}

function isWordChar(ch: string): boolean {
	return /[A-Za-z0-9_]/.test(ch);
}

function charKind(ch: string): "word" | "punct" {
	return isWordChar(ch) ? "word" : "punct";
}

function cloneSnapshot(api: EditorRuntime): {
	lines: string[];
	cursorLine: number;
	cursorCol: number;
	lastAction: string | null;
	jumpMode: string | null;
	preferredVisualCol: number | null;
	snappedFromCursorCol: number | null;
	historyIndex: number;
	lastSearch: SearchState | null;
} {
	return {
		lines: [...api.state.lines],
		cursorLine: api.state.cursorLine,
		cursorCol: api.state.cursorCol,
		lastAction: api.lastAction,
		jumpMode: api.jumpMode,
		preferredVisualCol: api.preferredVisualCol,
		snappedFromCursorCol: api.snappedFromCursorCol,
		historyIndex: api.historyIndex,
		lastSearch: null,
	};
}

function restoreSnapshot(
	api: EditorRuntime,
	snapshot: ReturnType<typeof cloneSnapshot>,
): void {
	api.state.lines = [...snapshot.lines];
	api.state.cursorLine = snapshot.cursorLine;
	api.state.cursorCol = snapshot.cursorCol;
	api.lastAction = snapshot.lastAction;
	api.jumpMode = snapshot.jumpMode;
	api.preferredVisualCol = snapshot.preferredVisualCol;
	api.snappedFromCursorCol = snapshot.snappedFromCursorCol;
	api.historyIndex = snapshot.historyIndex;
	api.setCursorCol(snapshot.cursorCol);
}

function posToIndex(lines: string[], pos: CursorPos): number {
	let index = 0;
	for (let line = 0; line < pos.line; line++) {
		index += (lines[line] ?? "").length + 1;
	}
	return index + pos.col;
}

function indexToPos(lines: string[], index: number): CursorPos {
	let remaining = Math.max(0, index);
	for (let line = 0; line < lines.length; line++) {
		const lineText = lines[line] ?? "";
		if (remaining <= lineText.length) {
			return { line, col: remaining };
		}
		remaining -= lineText.length + 1;
	}
	const lastLine = Math.max(0, lines.length - 1);
	return { line: lastLine, col: (lines[lastLine] ?? "").length };
}

function replaceRange(text: string, start: number, end: number, replacement: string): string {
	const from = Math.max(0, Math.min(start, end));
	const to = Math.max(0, Math.max(start, end));
	return text.slice(0, from) + replacement + text.slice(to);
}

function moveWordForward(text: string, index: number, bigWord = false): number {
	let i = Math.min(text.length, index);
	if (i < text.length) i++;

	while (i < text.length && isWhitespaceChar(text[i]!)) i++;
	if (i >= text.length) return text.length;
	if (bigWord) return i;

	const kind = charKind(text[i]!);
	while (i < text.length && !isWhitespaceChar(text[i]!) && charKind(text[i]!) === kind) i++;
	while (i < text.length && isWhitespaceChar(text[i]!)) i++;
	return Math.min(i, text.length);
}

function moveWordBackward(text: string, index: number, bigWord = false): number {
	if (index <= 0) return 0;
	let i = Math.min(text.length - 1, index - 1);

	while (i > 0 && isWhitespaceChar(text[i]!)) i--;
	if (bigWord) {
		while (i > 0 && !isWhitespaceChar(text[i - 1]!)) i--;
		return i;
	}

	const kind = charKind(text[i]!);
	while (i > 0 && !isWhitespaceChar(text[i - 1]!) && charKind(text[i - 1]!) === kind) i--;
	return i;
}

function moveWordEnd(text: string, index: number, bigWord = false): number {
	if (text.length === 0) return 0;

	// Vim-style `e` / `E` should move to the end of the current word when the
	// cursor is inside it, and to the end of the next word when already at the
	// word boundary.
	let i = Math.min(text.length, index);
	if (i < text.length) i++;

	while (i < text.length && isWhitespaceChar(text[i]!)) i++;
	if (i >= text.length) return text.length;
	if (bigWord) {
		while (i + 1 < text.length && !isWhitespaceChar(text[i + 1]!)) i++;
		return i;
	}

	const kind = charKind(text[i]!);
	while (i + 1 < text.length && !isWhitespaceChar(text[i + 1]!) && charKind(text[i + 1]!) === kind) i++;
	return i;
}

function firstNonBlankColumn(line: string): number {
	const match = line.match(/\S/);
	return match ? match.index ?? 0 : line.length;
}

function isBlankLine(line: string): boolean {
	return line.trim().length === 0;
}

function normalizeCount(count: string): number {
	if (!count) return 1;
	const parsed = Number.parseInt(count, 10);
	return Number.isFinite(parsed) && parsed > 0 ? parsed : 1;
}

class VimPromptEditor extends CustomEditor {
	private mode: Mode = "insert";
	private countBuffer = "";
	private pendingOperator: PendingOperator | null = null;
	private pendingTextObjectPrefix: PendingTextObjectPrefix | null = null;
	private pendingPrefix: PendingPrefix | null = null;
	private lastSearch: SearchState | null = null;
	private lastYankLines: string[] | null = null;
	private lastYankText = "";
	private lastYankLinewise = false;
	private suppressRender = false;

	constructor(tui: any, theme: any, keybindings: any) {
		super(tui, theme, keybindings);
		this.applyModeStyling();
	}

	private get api(): EditorRuntime {
		return this as unknown as EditorRuntime;
	}

	private clearPending(): void {
		this.countBuffer = "";
		this.pendingOperator = null;
		this.pendingTextObjectPrefix = null;
		this.pendingPrefix = null;
	}

	private renderModeLabel(): string {
		const modeText = this.mode === "insert" ? " INSERT " : " NORMAL ";
		const pieces = [this.countBuffer, this.pendingOperator ?? "", this.pendingTextObjectPrefix ?? "", this.pendingPrefix ?? ""].filter(Boolean);
		const suffix = pieces.length > 0 ? ` ${pieces.join("")}` : "";
		return `${modeText}${suffix}`;
	}

	private requestRender(): void {
		if (!this.suppressRender) {
			this.api.tui.requestRender();
		}
	}

	private applyModeStyling(): void {
		this.borderColor = (str: string) =>
			this.mode === "insert" ? str : `\x1b[38;5;137m${str}\x1b[0m`;
	}

	private commitChange(nextLines: string[], cursor: CursorPos, lastAction: string | null = null): void {
		const api = this.api;
		api.cancelAutocomplete?.();
		api.pushUndoSnapshot?.();
		api.historyIndex = -1;
		api.state.lines = nextLines.length > 0 ? nextLines : [""];
		api.state.cursorLine = Math.max(0, Math.min(cursor.line, api.state.lines.length - 1));
		api.setCursorCol(Math.max(0, Math.min(cursor.col, (api.state.lines[api.state.cursorLine] ?? "").length)));
		api.lastAction = lastAction;
		api.onChange?.(api.getText());
		this.requestRender();
	}

	private setCursor(pos: CursorPos): void {
		const api = this.api;
		api.state.cursorLine = Math.max(0, Math.min(pos.line, api.state.lines.length - 1));
		api.setCursorCol(Math.max(0, Math.min(pos.col, (api.state.lines[api.state.cursorLine] ?? "").length)));
		this.requestRender();
	}

	private currentIndex(): number {
		const api = this.api;
		return posToIndex(api.state.lines, { line: api.state.cursorLine, col: api.state.cursorCol });
	}

	private setCursorFromIndex(index: number): void {
		this.setCursor(indexToPos(this.api.state.lines, index));
	}

	private currentLineText(): string {
		return this.api.state.lines[this.api.state.cursorLine] ?? "";
	}

	private lineStartIndex(line: number): number {
		return posToIndex(this.api.state.lines, { line, col: 0 });
	}

	private lineEndIndex(line: number): number {
		return posToIndex(this.api.state.lines, { line, col: (this.api.state.lines[line] ?? "").length });
	}

	private performMotion(kind: MotionKind, count = 1, char?: string): void {
		const api = this.api;
		const times = Math.max(1, count);
		const lineCount = api.state.lines.length;

		switch (kind) {
			case "h":
				for (let i = 0; i < times; i++) api.moveCursor(0, -1);
				return;
			case "l":
				for (let i = 0; i < times; i++) api.moveCursor(0, 1);
				return;
			case "j":
				for (let i = 0; i < times; i++) api.moveCursor(1, 0);
				return;
			case "k":
				for (let i = 0; i < times; i++) api.moveCursor(-1, 0);
				return;
			case "w":
			case "W": {
				const bigWord = kind === "W";
				for (let i = 0; i < times; i++) {
					const idx = moveWordForward(api.getText(), this.currentIndex(), bigWord);
					this.setCursorFromIndex(idx);
				}
				return;
			}
			case "b":
			case "B": {
				const bigWord = kind === "B";
				for (let i = 0; i < times; i++) {
					const idx = moveWordBackward(api.getText(), this.currentIndex(), bigWord);
					this.setCursorFromIndex(idx);
				}
				return;
			}
			case "e":
			case "E": {
				const bigWord = kind === "E";
				for (let i = 0; i < times; i++) {
					const idx = moveWordEnd(api.getText(), this.currentIndex(), bigWord);
					this.setCursorFromIndex(idx);
				}
				return;
			}
			case "0":
				api.moveToLineStart();
				return;
			case "^": {
				const line = this.currentLineText();
				this.setCursor({ line: api.state.cursorLine, col: firstNonBlankColumn(line) });
				return;
			}
			case "$":
				api.moveToLineEnd();
				return;
			case "gg": {
				const targetLine = Math.max(0, Math.min(lineCount - 1, (count > 0 ? count - 1 : 0)));
				this.setCursor({ line: targetLine, col: 0 });
				return;
			}
			case "G": {
				const targetLine = count > 1 ? Math.max(0, Math.min(lineCount - 1, count - 1)) : lineCount - 1;
				this.setCursor({ line: targetLine, col: 0 });
				return;
			}
			case "H":
				this.setCursor({ line: 0, col: 0 });
				return;
			case "M":
				this.setCursor({ line: Math.floor((lineCount - 1) / 2), col: 0 });
				return;
			case "L":
				this.setCursor({ line: lineCount - 1, col: 0 });
				return;
			case "f":
			case "F":
			case "t":
			case "T": {
				if (!char) return;
				const line = this.currentLineText();
				let cursor = this.api.state.cursorCol;
				for (let i = 0; i < times; i++) {
					if (kind === "f" || kind === "t") {
						const found = line.indexOf(char, cursor + 1);
						if (found === -1) return;
						cursor = kind === "f" ? found : Math.max(0, found - 1);
					} else {
						const found = line.lastIndexOf(char, Math.max(0, cursor - 1));
						if (found === -1) return;
						cursor = kind === "F" ? found : Math.min(line.length, found + 1);
					}
				}
				this.setCursor({ line: api.state.cursorLine, col: cursor });
				this.lastSearch = { kind, char, count: times };
				return;
			}
			case ";": {
				if (!this.lastSearch) return;
				this.performMotion(this.lastSearch.kind, this.lastSearch.count, this.lastSearch.char);
				return;
			}
			case ",": {
				if (!this.lastSearch) return;
				const reversed = this.lastSearch.kind === "f" ? "F" : this.lastSearch.kind === "F" ? "f" : this.lastSearch.kind === "t" ? "T" : "t";
				this.performMotion(reversed, this.lastSearch.count, this.lastSearch.char);
				return;
			}
		}
	}

	private captureMotion(kind: MotionKind, count = 1, char?: string): CursorPos {
		const api = this.api;
		const snapshot = cloneSnapshot(api);
		const previousSearch = this.lastSearch;
		this.suppressRender = true;
		try {
			this.performMotion(kind, count, char);
			return { line: api.state.cursorLine, col: api.state.cursorCol };
		} finally {
			restoreSnapshot(api, snapshot);
			this.lastSearch = previousSearch;
			this.suppressRender = false;
		}
	}

	private selectRangeForMotion(kind: MotionKind, count = 1, char?: string): {
		start: number;
		end: number;
		inclusive: boolean;
		forward: boolean;
	} {
		const api = this.api;
		const origin = this.currentIndex();
		const targetPos = this.captureMotion(kind, count, char);
		const target = posToIndex(api.state.lines, targetPos);
		const inclusive = kind === "e" || kind === "E" || kind === "f" || kind === "F";
		const forward = target >= origin;
		if (forward) {
			return { start: origin, end: target + (inclusive ? 1 : 0), inclusive, forward };
		}
		return { start: target, end: origin + (inclusive ? 1 : 0), inclusive, forward };
	}

	private isEscapedInLine(line: string, index: number): boolean {
		let backslashes = 0;
		for (let i = index - 1; i >= 0 && line[i] === "\\"; i--) {
			backslashes++;
		}
		return backslashes % 2 === 1;
	}

	private findTokenStart(text: string, index: number, bigWord: boolean): number | null {
		if (text.length === 0) return null;
		let i = Math.max(0, Math.min(index, text.length - 1));
		if (isWhitespaceChar(text[i]!)) {
			while (i < text.length && isWhitespaceChar(text[i]!)) i++;
			if (i >= text.length) {
				i = Math.min(index - 1, text.length - 1);
				while (i >= 0 && isWhitespaceChar(text[i]!)) i--;
				if (i < 0) return null;
			}
		}
		const kind = bigWord ? null : charKind(text[i]!);
		while (i > 0 && !isWhitespaceChar(text[i - 1]!) && (bigWord || charKind(text[i - 1]!) === kind)) i--;
		return i;
	}

	private findTokenEndExclusive(text: string, start: number, bigWord: boolean): number {
		let i = Math.max(0, Math.min(start, text.length - 1));
		const kind = bigWord ? null : charKind(text[i]!);
		while (i + 1 < text.length && !isWhitespaceChar(text[i + 1]!) && (bigWord || charKind(text[i + 1]!) === kind)) i++;
		return i + 1;
	}

	private findWordTextObjectRange(prefix: PendingTextObjectPrefix, object: "w" | "W", count: number): { start: number; end: number } | null {
		const text = this.api.getText();
		if (text.length === 0) return null;
		const bigWord = object === "W";
		let start = this.findTokenStart(text, this.currentIndex(), bigWord);
		if (start === null) return null;
		let end = this.findTokenEndExclusive(text, start, bigWord);

		if (prefix === "a") {
			while (start > 0 && isWhitespaceChar(text[start - 1]!)) start--;
			while (end < text.length && isWhitespaceChar(text[end]!)) end++;
		}

		for (let i = 1; i < count; i++) {
			const nextStart = this.findTokenStart(text, end, bigWord);
			if (nextStart === null) break;
			end = this.findTokenEndExclusive(text, nextStart, bigWord);
			if (prefix === "a") {
				while (end < text.length && isWhitespaceChar(text[end]!)) end++;
			}
		}

		return { start, end };
	}

	private findPairTextObjectRange(prefix: PendingTextObjectPrefix, open: string, close: string, count: number): { start: number; end: number } | null {
		const line = this.currentLineText();
		const lineStart = this.lineStartIndex(this.api.state.cursorLine);
		const cursor = this.api.state.cursorCol;
		let searchFrom = Math.min(cursor, line.length - 1);
		let openIndex = -1;
		let closeIndex = -1;

		for (let iteration = 0; iteration < Math.max(1, count); iteration++) {
			openIndex = -1;
			closeIndex = -1;
			for (let i = searchFrom; i >= 0; i--) {
				if (line[i] === open) {
					let depth = 0;
					for (let j = i + 1; j < line.length; j++) {
						if (line[j] === open) depth++;
						else if (line[j] === close) {
							if (depth === 0) {
								if (i <= cursor && cursor <= j) {
									openIndex = i;
									closeIndex = j;
									searchFrom = j + 1;
									break;
								}
								break;
							}
							depth--;
						}
					}
					if (openIndex !== -1) break;
				}
			}
			if (openIndex === -1 || closeIndex === -1) break;
		}

		if (openIndex === -1 || closeIndex === -1) return null;
		const start = prefix === "i" ? openIndex + 1 : openIndex;
		const end = prefix === "i" ? closeIndex : closeIndex + 1;
		return { start: lineStart + start, end: lineStart + end };
	}

	private findQuoteTextObjectRange(prefix: PendingTextObjectPrefix, quote: string, count: number): { start: number; end: number } | null {
		const line = this.currentLineText();
		const lineStart = this.lineStartIndex(this.api.state.cursorLine);
		let cursor = this.api.state.cursorCol;
		let left = -1;
		let right = -1;

		for (let iteration = 0; iteration < Math.max(1, count); iteration++) {
			left = -1;
			right = -1;
			for (let i = Math.min(cursor, line.length - 1); i >= 0; i--) {
				if (line[i] === quote && !this.isEscapedInLine(line, i)) {
					left = i;
					break;
				}
			}
			if (left === -1) break;
			for (let i = Math.max(left + 1, cursor); i < line.length; i++) {
				if (line[i] === quote && !this.isEscapedInLine(line, i)) {
					right = i;
					break;
				}
			}
			if (right === -1) break;
			cursor = right + 1;
		}

		if (left === -1 || right === -1) return null;
		const start = prefix === "i" ? left + 1 : left;
		const end = prefix === "i" ? right : right + 1;
		return { start: lineStart + start, end: lineStart + end };
	}

	private findParagraphTextObjectRange(prefix: PendingTextObjectPrefix, count: number): { start: number; end: number } | null {
		const lines = this.api.state.lines;
		if (lines.length === 0) return null;

		let startLine = this.api.state.cursorLine;
		let endLine = this.api.state.cursorLine;

		for (let iteration = 0; iteration < Math.max(1, count); iteration++) {
			while (startLine > 0 && !isBlankLine(lines[startLine - 1] ?? "")) startLine--;
			while (endLine < lines.length - 1 && !isBlankLine(lines[endLine + 1] ?? "")) endLine++;
			if (iteration < count - 1) {
				let nextLine = endLine + 1;
				while (nextLine < lines.length && isBlankLine(lines[nextLine] ?? "")) nextLine++;
				if (nextLine >= lines.length) break;
				startLine = nextLine;
				endLine = nextLine;
			}
		}

		if (prefix === "a") {
			while (startLine > 0 && isBlankLine(lines[startLine - 1] ?? "")) startLine--;
			while (endLine < lines.length - 1 && isBlankLine(lines[endLine + 1] ?? "")) endLine++;
		}

		const start = posToIndex(lines, { line: startLine, col: 0 });
		const end = endLine < lines.length - 1 ? posToIndex(lines, { line: endLine + 1, col: 0 }) : this.api.getText().length;
		return { start, end };
	}

	private resolveTextObjectRange(prefix: PendingTextObjectPrefix, object: string, count: number): { start: number; end: number } | null {
		switch (object) {
			case "w":
			case "W":
				return this.findWordTextObjectRange(prefix, object, count);
			case "p":
				return this.findParagraphTextObjectRange(prefix, count);
			case "(":
			case ")":
				return this.findPairTextObjectRange(prefix, "(", ")", count);
			case "[":
			case "]":
				return this.findPairTextObjectRange(prefix, "[", "]", count);
			case "{":
			case "}":
				return this.findPairTextObjectRange(prefix, "{", "}", count);
			case "<":
			case ">":
				return this.findPairTextObjectRange(prefix, "<", ">", count);
			case '"':
			case "'":
			case "`":
				return this.findQuoteTextObjectRange(prefix, object, count);
			default:
				return null;
		}
	}

	private applyTextObjectOperator(kind: PendingOperator, prefix: PendingTextObjectPrefix, object: string, count: number): boolean {
		const range = this.resolveTextObjectRange(prefix, object, count);
		if (!range) return false;
		const api = this.api;
		const text = api.getText();
		const deleted = text.slice(range.start, range.end);
		if (kind === "y") {
			this.lastYankLines = deleted.includes("\n") ? deleted.split("\n") : null;
			this.lastYankText = deleted;
			this.lastYankLinewise = deleted.includes("\n");
			api.killRing.push(deleted, {
				prepend: false,
				accumulate: api.lastAction === "yank",
			});
			api.lastAction = "yank";
			this.requestRender();
			return true;
		}

		const nextText = replaceRange(text, range.start, range.end, "");
		const nextLines = nextText.split("\n");
		const cursor = indexToPos(nextLines, range.start);
		this.lastYankLines = deleted.includes("\n") ? deleted.split("\n") : null;
		this.lastYankText = deleted;
		this.lastYankLinewise = deleted.includes("\n");
		api.killRing.push(deleted, {
			prepend: false,
			accumulate: api.lastAction === "kill",
		});
		this.commitChange(nextLines, cursor, "kill");
		if (kind === "c") {
			this.mode = "insert";
			this.requestRender();
		}
		return true;
	}

	private deleteCurrentLine(count = 1): void {
		const api = this.api;
		const lines = [...api.state.lines];
		const start = api.state.cursorLine;
		const end = Math.min(lines.length, start + Math.max(1, count));
		const deletedLines = lines.slice(start, end);
		const nextLines = [...lines.slice(0, start), ...lines.slice(end)];
		const cursorLine = Math.min(start, Math.max(0, nextLines.length - 1));
		const cursorCol = 0;
		this.lastYankLines = deletedLines;
		this.lastYankText = deletedLines.join("\n");
		this.lastYankLinewise = true;
		api.killRing.push(this.lastYankText, {
			prepend: false,
			accumulate: api.lastAction === "kill",
		});
		this.commitChange(nextLines.length > 0 ? nextLines : [""], { line: cursorLine, col: cursorCol }, "kill");
	}

	private yankCurrentLine(count = 1): void {
		const api = this.api;
		const lines = api.state.lines;
		const start = api.state.cursorLine;
		const end = Math.min(lines.length, start + Math.max(1, count));
		const yankedLines = lines.slice(start, end);
		this.lastYankLines = yankedLines;
		this.lastYankText = yankedLines.join("\n");
		this.lastYankLinewise = true;
		api.killRing.push(this.lastYankText, {
			prepend: false,
			accumulate: api.lastAction === "yank",
		});
		api.lastAction = "yank";
		this.requestRender();
	}

	private deleteOrYankRange(kind: "d" | "c" | "y", motion: MotionKind, count = 1, char?: string): void {
		const api = this.api;
		const { start, end, forward } = this.selectRangeForMotion(motion, count, char);
		const text = api.getText();
		const deleted = text.slice(start, Math.max(start, end));
		if (kind === "y") {
			this.lastYankLines = null;
			this.lastYankText = deleted;
			this.lastYankLinewise = false;
			api.killRing.push(deleted, {
				prepend: false,
				accumulate: api.lastAction === "yank",
			});
			api.lastAction = "yank";
			this.requestRender();
			return;
		}

		const replacement = "";
		const nextText = replaceRange(text, start, Math.max(start, end), replacement);
		const nextLines = nextText.split("\n");
		const cursor = indexToPos(nextLines, start);
		this.lastYankLines = null;
		this.lastYankText = deleted;
		this.lastYankLinewise = false;
		api.killRing.push(deleted, {
			prepend: !forward,
			accumulate: api.lastAction === "kill",
		});
		this.commitChange(nextLines, cursor, "kill");
		if (kind === "c") {
			this.mode = "insert";
			this.requestRender();
		}
	}

	private paste(after: boolean, count = 1): void {
		const api = this.api;
		const registerText = api.killRing.peek() ?? this.lastYankText;
		if (!registerText) return;
		const repeat = Math.max(1, count);
		const linewise = this.lastYankLinewise || registerText.includes("\n");
		const text = repeat > 1 ? Array.from({ length: repeat }, () => registerText).join("") : registerText;

		if (linewise && this.lastYankLines) {
			const insertLines = Array.from({ length: repeat }, () => [...this.lastYankLines!]).flat();
			const lines = [...api.state.lines];
			const insertAt = after ? api.state.cursorLine + 1 : api.state.cursorLine;
			lines.splice(insertAt, 0, ...insertLines);
			this.commitChange(lines, { line: insertAt, col: 0 }, null);
			return;
		}

		const textBefore = api.getText();
		const cursorIndex = this.currentIndex();
		const insertAt = after ? Math.min(textBefore.length, cursorIndex + 1) : cursorIndex;
		const nextText = replaceRange(textBefore, insertAt, insertAt, text);
		const nextLines = nextText.split("\n");
		const cursor = indexToPos(nextLines, insertAt + text.length);
		this.commitChange(nextLines, cursor, null);
	}

	private openLine(after: boolean): void {
		const api = this.api;
		const lines = [...api.state.lines];
		const insertAt = after ? api.state.cursorLine + 1 : api.state.cursorLine;
		lines.splice(insertAt, 0, "");
		this.commitChange(lines, { line: insertAt, col: 0 }, null);
		this.mode = "insert";
		this.requestRender();
	}

	private replaceChar(ch: string): void {
		const api = this.api;
		const line = this.currentLineText();
		if (this.api.state.cursorCol >= line.length) return;
		const nextLine = line.slice(0, this.api.state.cursorCol) + ch + line.slice(this.api.state.cursorCol + 1);
		const lines = [...api.state.lines];
		lines[api.state.cursorLine] = nextLine;
		this.commitChange(lines, { line: api.state.cursorLine, col: api.state.cursorCol }, null);
	}

	private handleNormalPrintable(data: string): boolean {
		const api = this.api;
		const count = normalizeCount(this.countBuffer);

		if (this.pendingPrefix === "r") {
			if (!isPrintable(data)) {
				this.clearPending();
				return true;
			}
			this.replaceChar(data);
			this.clearPending();
			return true;
		}

		if (this.pendingPrefix === "f" || this.pendingPrefix === "F" || this.pendingPrefix === "t" || this.pendingPrefix === "T") {
			if (!isPrintable(data)) {
				this.clearPending();
				return true;
			}
			if (this.pendingOperator) {
				const op = this.pendingOperator;
				this.deleteOrYankRange(op, this.pendingPrefix, count, data);
				this.clearPending();
				if (op === "c") {
					this.mode = "insert";
					this.requestRender();
				}
				return true;
			}
			this.performMotion(this.pendingPrefix, count, data);
			this.lastSearch = { kind: this.pendingPrefix, char: data, count };
			this.clearPending();
			return true;
		}

		if (this.pendingPrefix === "g") {
			if (data === "g") {
				this.performMotion("gg", count);
				this.clearPending();
				return true;
			}
			if (data === "G") {
				this.performMotion("G", count);
				this.clearPending();
				return true;
			}
			if (data === "0" || data === "^" || data === "$") {
				this.performMotion(data as MotionKind, count);
				this.clearPending();
				return true;
			}
			this.clearPending();
			return true;
		}

		if (this.pendingOperator) {
			if (this.pendingTextObjectPrefix) {
				if (isPrintable(data)) {
					const op = this.pendingOperator;
					const prefix = this.pendingTextObjectPrefix;
					const handled = this.applyTextObjectOperator(op, prefix, data, count);
					this.clearPending();
					if (handled && op === "c") {
						this.mode = "insert";
						this.requestRender();
					}
					return true;
				}
				this.clearPending();
				return true;
			}

			if (data === this.pendingOperator) {
				const op = this.pendingOperator;
				if (op === "d") {
					this.deleteCurrentLine(count);
				} else if (op === "y") {
					this.yankCurrentLine(count);
				} else {
					this.deleteCurrentLine(count);
					this.mode = "insert";
					this.requestRender();
				}
				this.clearPending();
				return true;
			}

			if (data === "a" || data === "i") {
				this.pendingTextObjectPrefix = data as PendingTextObjectPrefix;
				return true;
			}

			if (isPrintable(data)) {
				if (data === "w" || data === "b" || data === "e" || data === "W" || data === "B" || data === "E" || data === "0" || data === "^" || data === "$" || data === "G" || data === "H" || data === "M" || data === "L") {
					const op = this.pendingOperator;
					this.deleteOrYankRange(op, data as MotionKind, count);
					this.clearPending();
					if (op === "c") {
						this.mode = "insert";
						this.requestRender();
					}
					return true;
				}
				if (data === "f" || data === "F" || data === "t" || data === "T") {
					this.pendingPrefix = data as PendingPrefix;
					return true;
				}
				this.clearPending();
				return true;
			}
		}

		if (data === "h" || data === "j" || data === "k" || data === "l") {
			this.performMotion(data as MotionKind, count);
			this.clearPending();
			return true;
		}

		if (data === "w" || data === "b" || data === "e" || data === "W" || data === "B" || data === "E" || data === "0" || data === "^" || data === "$" || data === "G" || data === "H" || data === "M" || data === "L") {
			this.performMotion(data as MotionKind, count);
			this.clearPending();
			return true;
		}

		if (data === "f" || data === "F" || data === "t" || data === "T" || data === "g" || data === "r") {
			this.pendingPrefix = data as PendingPrefix;
			return true;
		}

		if (data === "d" || data === "c" || data === "y") {
			this.pendingOperator = data as PendingOperator;
			return true;
		}

		if (data === "x") {
			for (let i = 0; i < count; i++) api.handleForwardDelete();
			this.clearPending();
			this.requestRender();
			return true;
		}

		if (data === "X") {
			for (let i = 0; i < count; i++) api.handleBackspace();
			this.clearPending();
			this.requestRender();
			return true;
		}

		if (data === "p" || data === "P") {
			this.paste(data === "p", count);
			this.clearPending();
			return true;
		}

		if (data === "o" || data === "O") {
			this.openLine(data === "o");
			this.clearPending();
			return true;
		}

		if (data === "a" || data === "A" || data === "i" || data === "I") {
			if (data === "a") {
				const line = this.currentLineText();
				if (this.api.state.cursorCol < line.length) {
					this.performMotion("l", 1);
				}
			}
			if (data === "A") {
				this.performMotion("$");
			}
			if (data === "I") {
				this.performMotion("^");
			}
			this.mode = "insert";
			this.clearPending();
			this.requestRender();
			return true;
		}

		if (data === "s") {
			api.handleForwardDelete();
			this.mode = "insert";
			this.clearPending();
			this.requestRender();
			return true;
		}

		if (data === "D") {
			api.deleteToEndOfLine();
			this.clearPending();
			this.requestRender();
			return true;
		}

		if (data === "C") {
			api.deleteToEndOfLine();
			this.mode = "insert";
			this.clearPending();
			this.requestRender();
			return true;
		}

		if (data === "S") {
			this.deleteCurrentLine(count);
			this.mode = "insert";
			this.clearPending();
			this.requestRender();
			return true;
		}

		if (data === "u") {
			for (let i = 0; i < count; i++) api.undo();
			this.clearPending();
			this.requestRender();
			return true;
		}

		if (data === "g") {
			this.pendingPrefix = "g";
			return true;
		}

		if (data === "^") {
			this.performMotion("^", count);
			this.clearPending();
			return true;
		}

		if (data === ";" || data === ",") {
			this.performMotion(data as MotionKind, count);
			this.clearPending();
			return true;
		}

		if (data === "r") {
			this.pendingPrefix = "r";
			return true;
		}

		if (data === "" || isPrintable(data)) {
			return true;
		}

		return false;
	}

	handleInput(data: string): void {
		if (matchesKey(data, "escape")) {
			if (this.mode === "insert") {
				this.mode = "normal";
				this.clearPending();
				this.requestRender();
				return;
			}

			if (this.pendingOperator || this.pendingPrefix || this.countBuffer) {
				this.clearPending();
				this.requestRender();
				return;
			}

			super.handleInput(data);
			return;
		}

		if (this.mode === "insert") {
			super.handleInput(data);
			return;
		}

		if (data.length === 1 && /[0-9]/.test(data) && !this.pendingPrefix) {
			if (data === "0" && !this.countBuffer) {
				this.performMotion("0");
				this.clearPending();
				return;
			}
			this.countBuffer += data;
			this.requestRender();
			return;
		}

		if (this.handleNormalPrintable(data)) {
			return;
		}

		if (!isPrintable(data)) {
			super.handleInput(data);
		}
	}

	render(width: number): string[] {
		this.applyModeStyling();
		const lines = super.render(width);
		if (lines.length === 0) return lines;

		const label = this.renderModeLabel();
		const last = lines.length - 1;
		if (visibleWidth(lines[last] ?? "") >= label.length && width > label.length) {
			lines[last] = truncateToWidth(lines[last] ?? "", width - label.length, "") + label;
		}
		return lines;
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event: any, ctx: any) => {
		ctx.ui.setEditorComponent((tui: any, theme: any, keybindings: any) => new VimPromptEditor(tui, theme, keybindings));
	});
}
