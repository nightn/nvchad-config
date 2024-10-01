-- EXAMPLE 
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- if you just want default config for the servers then put them in a table
-- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
local lspconfig = require "lspconfig"
local servers = {
  "html",
  "cssls",
  "bashls",  -- bash-language-server
  "cmake",  -- cmake-language-server
  "clangd",  -- clangd
  "jedi_language_server",  -- jedi-language-server
}

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- typescript
lspconfig.ts_ls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

-- sourcekit
lspconfig.sourcekit.setup {
  -- the default filetypes of sourcekit contains c/cpp, we should redefine it
  -- see: https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/sourcekit.lua
  filetypes = { 'swift', 'objective-c', 'objective-cpp' },
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

