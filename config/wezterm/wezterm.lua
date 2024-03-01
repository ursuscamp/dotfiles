local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font("JetBrains Mono")
config.font_size = 14

config.keys = {
	{
		key = "|",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "\\",
		mods = "CTRL",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "j",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "X",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		key = "k",
		mods = "SUPER",
		action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
	},
	{
		key = "h",
		mods = "CTRL|ALT",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "l",
		mods = "CTRL|ALT",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		key = "j",
		mods = "CTRL|ALT",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
	{
		key = "k",
		mods = "CTRL|ALT",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "G",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local cwd = pane:get_current_working_dir()
			print("hello world")
			print(cwd)
			wezterm.mux.spawn_window({
				width = 200,
				height = 50,
				args = { "lazygit" },
				cwd = cwd.file_path,
			})
			-- wezterm.mux.spawn_window({
			-- 	width = 100,
			-- 	height = 100,
			-- 	cwd = cwd,
			-- 	args = { "lazygit" },
			-- })
		end)
	},
	{
		key = "LeftArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action.MoveTabRelative(-1),
	},
	{
		key = "RightArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action.MoveTabRelative(1),
	},
}

config.colors = {
	quick_select_label_fg = { Color = "black" },
	quick_select_label_bg = { Color = "yellow" },
}

config.quick_select_patterns = {
	"[A-Za-z0-9][A-Za-z0-9\\-_\\.@]*",
}

config.set_environment_variables = {
	PATH = "/opt/homebrew/bin:/usr/local/bin:" .. os.getenv("PATH"),
}

return config
