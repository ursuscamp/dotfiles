version = "0.21.5"

local home = os.getenv("HOME")
local xpm_path = home .. "/.local/share/xplr/dtomvan/xpm.xplr"
local xpm_url = "https://github.com/dtomvan/xpm.xplr"

package.path = package.path
    .. ";"
    .. xpm_path
    .. "/?.lua;"
    .. xpm_path
    .. "/?/init.lua"

os.execute(
	string.format(
		"[ -e '%s' ] || git clone '%s' '%s'",
		xpm_path,
		xpm_url,
		xpm_path
	)
)

require("xpm").setup({
	plugins = {
		-- Let xpm manage itself
		'dtomvan/xpm.xplr',
		'sayanarijit/fzf.xplr',
		'prncss-xyz/icons.xplr',
		{
			'dtomvan/extra-icons.xplr',
			after = function()
				xplr.config.general.table.row.cols[2] = { format = "custom.icons_dtomvan_col_1" }
			end
		},
	},
	auto_install = true,
	auto_cleanup = true,
})

require("fzf").setup {
	mode = "default",
	key = "ctrl-f",
	bin = "fzf",
	-- args = "--preview 'pistol {}'",
	recursive = true, -- If true, search all files under $PWD
	enter_dir = false, -- Enter if the result is directory
}

require("icons").setup()
