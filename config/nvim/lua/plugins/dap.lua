local function ruby(dap)
	local port = 34345
	dap.adapters.ruby = function(callback, config)
		callback {
			type = "server",
			host = "127.0.0.1",
			port = port,
			executable = {
				command = "bundle",
				args = config.args,
			},
		}
	end

	dap.configurations.ruby = {
		{
			type = "ruby",
			name = "debug quick script",
			request = "attach",
			localfs = true,
			port = port,
			args = { "exec", "rdbg", "-e", "binding.b", "--open", "--port", port,
				"-c", "--", "bundle", "exec", "ruby", "${file}" },
		},
		{
			type = "ruby",
			name = "debug rails",
			request = "attach",
			localfs = true,
			port = port,
			args = { "exec", "rdbg", "-n", "--open", "--port", port,
				"-c", "--", "bundle", "exec", "rails", "s" },
		},
		{
			type = "ruby",
			name = "run current spec file",
			request = "attach",
			localfs = true,
			command = "rspec",
			script = "${file}",
			port = port,
		},
	}
end

return {
	'mfussenegger/nvim-dap',
	dependencies = {
		'rcarriga/nvim-dap-ui',
		'nvim-neotest/nvim-nio',
		'mfussenegger/nvim-dap-python',
	},
	keys = {
		{ '<leader>dc', ':DapContinue<CR>',         desc = 'Continue' },
		{ '<leader>db', ':DapToggleBreakpoint<CR>', desc = 'Toggle breakpoint' },
		{ '<leader>dr', ':DapToggleRepl<CR>',       desc = 'Open REPL' },
		{ '<leader>ds', ':DapTerminate<CR>',        desc = 'Stop' },
		{ '<leader>dn', ':DapStepOver<CR>',         desc = 'Step over' },
		{ '<leader>di', ':DapStepInto<CR>',         desc = 'Step into' },
		{ '<leader>do', ':DapStepOut<CR>',          desc = 'Step out' },
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")
		dapui.setup()
		require('dap-python').setup('python3')
		ruby(dap)
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end
	end
}
