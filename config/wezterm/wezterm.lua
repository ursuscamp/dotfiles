local wezterm = require("wezterm")

local config = {}

local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')

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
	{
		key = 'E',
		mods = 'CTRL|SHIFT',
		action = wezterm.action.PromptInputLine {
			description = 'Enter new name for tab',
			action = wezterm.action_callback(function(window, _, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		},
	},
}

-- Tabs

-- config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_frame = {
	font_size = 13
}


-- Background image stuff (disabled for now)

-- config.window_background_image = '/Users/rbreen/Downloads/bg.jpg'
-- config.window_background_image_hsb = {
-- 	brightness = 0.1,
-- }
-- config.window_background_opacity = 0.6
-- config.text_background_opacity = 0.9

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

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

function on_format_tab_title(tab, _tabs, _panes, _config, _hover, _max_width)
	local zoomed = ''
	local index = tab.tab_index + 1
	local title = tab_title(tab)
	if tab.active_pane.is_zoomed then
		zoomed = '   🔍'
	end
	return {
		{ Text = string.format(' %d: %s%s ', index, title, zoomed) }
	}
end

wezterm.on('format-tab-title', on_format_tab_title)

return config
