return {
	'mistricky/codesnap.nvim',
	build = 'make',
	cmd = { 'CodeSnap', 'CodeSnapSave', 'CodeSnapHighlight', 'CodeSnapSaveHighlight' },
	opts = {
		watermark = "",
		save_path = "~/Downloads"
	}
}
