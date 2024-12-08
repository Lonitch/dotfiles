return {
	"rust-lang/rust.vim",
	ft = "rust",
	init = function()
		-- auto-format at save
		vim.g.rustfmt_autosave = 1

		-- Workaround to ignore the ServerCancelled error: https://github.com/neovim/neovim/issues/30985
		for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
			local default_diagnostic_handler = vim.lsp.handlers[method]
			vim.lsp.handlers[method] = function(err, result, context, config)
				if err ~= nil and err.code == -32802 then
					return
				end
				return default_diagnostic_handler(err, result, context, config)
			end
		end
	end,
}
