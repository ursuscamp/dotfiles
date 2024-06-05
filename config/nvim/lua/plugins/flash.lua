local f = function()
	return require("flash")
end

return {
	'folke/flash.nvim',
	keys = {
		{ "s",         mode = { "n", "x", "o" }, function() f().jump() end,              desc = "Flash" },
		{ "<leader>S", mode = { "n", "x", "o" }, function() f().treesitter() end,        desc = "Flash Treesitter" },
		{ "r",         mode = "o",               function() f().remote() end,            desc = "Remote Flash" },
		{ "R",         mode = { "o", "x" },      function() f().treesitter_search() end, desc = "Treesitter Search" },
		{ "<c-s>",     mode = { "c" },           function() f().toggle() end,            desc = "Toggle Flash Search" },
	},
}
