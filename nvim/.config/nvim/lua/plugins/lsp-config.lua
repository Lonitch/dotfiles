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
			local servers = {
				jedi_language_server = {
					capabilities = capabilities,
				},
				tinymist = {
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
				},
				tailwindcss = {
					capabilities = capabilities,
					cmd = { "bun", "run", "--bun", "tailwindcss-language-server", "--stdio" },
					filetypes = { "javascriptreact", "typescriptreact" },
				},
				cssls = {
					capabilities = capabilities,
					cmd = { "bun", "run", "--bun", "vscode-css-language-server", "--stdio" },
				},
				html = {
					capabilities = capabilities,
					cmd = { "bun", "run", "--bun", "vscode-html-language-server", "--stdio" },
				},
				eslint = {
					capabilities = capabilities,
					cmd = { "bun", "run", "--bun", "vscode-eslint-language-server", "--stdio" },
				},
				lua_ls = {
					capabilities = capabilities,
				},
				ts_ls = {
					capabilities = capabilities,
					cmd = { "bun", "run", "--bun", "typescript-language-server", "--stdio" },
				},
				bashls = {
					capabilities = capabilities,
					cmd = { "bun", "run", "--bun", "bash-language-server", "start" },
					filetypes = { "sh", "zsh" },
				},
			}

			for server, config in pairs(servers) do
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
			end
		end,
	},
}
