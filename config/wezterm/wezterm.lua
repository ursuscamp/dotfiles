local wezterm = require("wezterm")

local config = {}

local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- config.color_scheme = "Tokyo Night"
config.color_scheme = "Dracula"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13

config.scrollback_lines = 50000
config.enable_kitty_keyboard = true

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
	{
		key = 'O',
		mods = 'CTRL|SHIFT',
		action = wezterm.action.EmitEvent 'trigger-vim-with-scrollback',
	},
	{
		key = 'S',
		mods = 'CTRL|SHIFT',
		action = wezterm.action.PaneSelect {
			mode = 'SwapWithActiveKeepFocus'
		}
	}
}

-- Tabs

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 30
config.window_decorations = "RESIZE"
config.window_frame = {
	font_size = 13
}

-- config.window_background_opacity = 0.80
-- config.macos_window_background_blur = 50

config.inactive_pane_hsb = {
	-- saturation = 0.3,
	brightness = 0.6,
}

config.colors = {
	quick_select_label_fg = { Color = "white" },
	quick_select_label_bg = { Color = "magenta" },
}

config.quick_select_patterns = {
	"[A-Za-z0-9][A-Za-z0-9\\-_\\.@]*",
}

config.set_environment_variables = {
	PATH = "/opt/homebrew/bin:/usr/local/bin:" .. os.getenv("PATH"),
}

config.command_palette_bg_color = "#282a36"
config.command_palette_fg_color = "#bd93f9"
config.switch_to_last_active_tab_when_closing_tab = true
config.use_resize_increments = true

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
	local zoomed_left = ''
	local zoomed_right = ''
	local index = tab.tab_index + 1
	local title = tab_title(tab)
	if tab.active_pane.is_zoomed then
		zoomed_left = wezterm.nerdfonts.fa_angle_double_right
		zoomed_right = wezterm.nerdfonts.fa_angle_double_left
	end
	local format_items = {}

	-- FormatItem: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html
	if tab.is_active then
		table.insert(format_items, { Background = { Color = '#bd93f9' } })
		table.insert(format_items, { Foreground = { Color = '#282a36' } })
	else
		table.insert(format_items, { Background = { Color = '#282a36' } })
		table.insert(format_items, { Foreground = { Color = '#bd93f9' } })
	end

	-- it seems like the text must be inserted last
	table.insert(format_items, { Text = string.format(' %s %d: %s %s ', zoomed_left, index, title, zoomed_right) })
	return format_items
end

wezterm.on('format-tab-title', on_format_tab_title)


wezterm.on('trigger-vim-with-scrollback', function(window, pane)
	local io = require 'io'
	local os = require 'os'
	local act = wezterm.action

	-- Retrieve the text from the pane
	local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)

	-- Create a temporary file to pass to vim
	local name = os.tmpname()
	local f = io.open(name, 'w+')
	f:write(text)
	f:flush()
	f:close()

	-- Open a new window running vim and tell it to open the file
	window:perform_action(
		act.SpawnCommandInNewTab {
			args = { 'nvim', name },
		},
		pane
	)

	-- Wait "enough" time for vim to read the file before we remove it.
	-- The window creation and process spawn are asynchronous wrt. running
	-- this script and are not awaitable, so we just pick a number.
	--
	-- Note: We don't strictly need to remove this file, but it is nice
	-- to avoid cluttering up the temporary directory.
	wezterm.sleep_ms(1000)
	os.remove(name)
end)

return config
