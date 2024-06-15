local wezterm = require("wezterm")

local config = {}

-- local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')
local smart_splits = wezterm.plugin.require('https://github.com/ursuscamp/smart-splits.nvim')

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = "Tokyo Night"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13

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
		key = "H",
		mods = "CTRL|SHIFT",
		action = wezterm.action.MoveTabRelative(-1),
	},
	{
		key = "L",
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

smart_splits.apply_to_config(config, {
	default_amount = 5,
	-- the default config is here, if you'd like to use the default keys,
	-- you can omit this configuration table parameter and just use
	-- smart_splits.apply_to_config(config)
	-- directional keys to use in order of: left, down, up, right
	direction_keys = { 'h', 'j', 'k', 'l' },
	-- modifier keys to combine with direction_keys
	modifiers = {
		move = 'CTRL', -- modifier to use for pane movement, e.g. CTRL+h to move left
		resize = 'META', -- modifier to use for pane resize, e.g. META+h to resize to the left
	},
})

return config
