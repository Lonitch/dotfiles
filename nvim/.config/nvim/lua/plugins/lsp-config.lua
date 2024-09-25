return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				-- define LSP servers here for LUA, RUST, JS/TS, and PYTHON
				ensure_installed = { "lua_ls", "rust_analyzer", "tsserver", "jedi_language_server", "typst_lsp" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lsp_disabled = vim.g.lsp_disabled or false
			if lsp_disabled then
				return
			end
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
			-- Capabilities required for the visualstudio lsps (css, html, etc)
			capabilities.textDocument.completion.completionItem.snippetSupport = true
			local lspconfig = require("lspconfig")
			lspconfig.jedi_language_server.setup({
				capabilities = capabilities,
			})
			require("lspconfig").typst_lsp.setup({
				settings = {
					exportPdf = "never", -- Choose onType, onSave or never.
					-- serverPath = "" -- Normally, there is no need to uncomment it.
				},
			})
			-- lspconfig.tailwindcss.setup({
			-- 	capabilities = capabilities,
			-- })
			lspconfig.cssls.setup({
				capabilities = capabilities,
			})
			lspconfig.html.setup({
				capabilities = capabilities,
			})
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.tsserver.setup({
				capabilities = capabilities,
				cmd = { "bun", "run", "typescript-language-server", "--stdio" },
			})
		end,
	},
}
