local function mapn(keys, command, desc)
	vim.keymap.set('n', keys, command, { desc = desc })
end

return {
	save_session = function()
		local name = "session"
		for dir in string.gmatch(vim.fn.getcwd(), "[^/]+") do
			name = dir
		end
		MiniSessions.write(name)
	end,

	mapn = mapn,

	mapleader = function(keys, command, desc)
		mapn('<leader>' .. keys, command, desc)
	end,

	lsppicker = function(scope)
		return function()
			MiniExtra.pickers.lsp({ scope = scope })
		end
	end,

	buff_diagnostics = function()
		MiniExtra.pickers.diagnostic({ scope = "current" })
	end
}
