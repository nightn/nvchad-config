require("nvchad.configs.lspconfig").defaults()

-- if you just want default config for the servers then put them in a table
-- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- read :h vim.lsp.config for changing options of lsp servers
local servers = {
  -- <lsp server name>, <Mason plugin name>
  "html",
  "cssls",
  "bashls", -- bash-language-server
  "cmake", -- cmake-language-server
  -- "clangd", -- clangd
  "jedi_language_server", -- jedi-language-server
  -- vue support. required: npm install -g @vue/language-server
  "vue_ls", -- vue-language-server
  "ts_ls", -- typescript-language-server
  "gn_language_server", -- gn-language-server
}
-- Use new vim.lsp.config API for Neovim 0.11+
vim.lsp.enable(servers)

local custom_clangd_query_driver = ""
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    -- Allow clangd to access these compilers
    "--query-driver=/usr/bin/clang++,/usr/bin/g++,/usr/bin/aarch64-linux-gnu-g++," .. custom_clangd_query_driver,
    "--background-index",
    "--clang-tidy",
    "--header-insertion=never",
  },
})
vim.lsp.enable("clangd")

-- sourcekit
vim.lsp.config("sourcekit", {
  -- the default filetypes of sourcekit contains c/cpp, we should redefine it
  -- see: https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/sourcekit.lua
  filetypes = { "swift", "objective-c", "objective-cpp" },
});
vim.lsp.enable("sourcekit")

