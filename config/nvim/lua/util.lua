return {
	save_session = function()
		local name = "session"
		for dir in string.gmatch(vim.fn.getcwd(), "[^/]+") do
			name = dir
		end
		MiniSessions.write(name)
	end
}
