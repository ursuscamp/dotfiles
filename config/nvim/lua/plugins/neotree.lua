MiniDeps.add({
	source = "nvim-neo-tree/neo-tree.nvim",
	checkout = "v3.x",
	depends = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	}
})

require('neo-tree').setup()
