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
				ensure_installed = { "lua_ls", "rust_analyzer", "jedi_language_server", "tinymist" },
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

			lspconfig.tinymist.setup({
				single_file_support = true,
				offset_encoding = "utf-8",
				root_dir = function()
					return vim.fn.getcwd()
				end,
				--- See [Configuration](https://github.com/Myriad-Dreamin/tinymist/blob/main/Configuration.md) for references.
				settings = {
					semanticTokens = "enable",
					formatterMode = "typstyle",
				},
			})
			-- require("lspconfig").typst_lsp.setup({
			--      filetypes = { "typst" },
			-- 	settings = {
			-- 		exportPdf = "never", -- Choose onType, onSave or never.
			-- 		-- serverPath = "" -- Normally, there is no need to uncomment it.
			-- 	},
			-- })

			lspconfig.tailwindcss.setup({
				capabilities = capabilities,
				cmd = { "bun", "run", "--bun", "tailwindcss-language-server", "--stdio" },
				filetypes = { "javascriptreact", "typescriptreact" },
			})
			lspconfig.cssls.setup({
				capabilities = capabilities,
				cmd = { "bun", "run", "--bun", "vscode-css-language-server", "--stdio" },
			})
			lspconfig.html.setup({
				capabilities = capabilities,
				cmd = { "bun", "run", "--bun", "vscode-html-language-server", "--stdio" },
			})
			lspconfig.eslint.setup({
				capabilities = capabilities,
				cmd = { "bun", "run", "--bun", "vscode-eslint-language-server", "--stdio" },
			})
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				cmd = { "bun", "run", "--bun", "typescript-language-server", "--stdio" },
			})
			lspconfig.bashls.setup({
				capabilities = capabilities,
				cmd = { "bun", "run", "--bun", "bash-language-server", "start" },
				filetypes = { "sh", "zsh" },
			})
		end,
	},
}
