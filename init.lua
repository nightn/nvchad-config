vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Return to last edit position when opening files (You want this!)
vim.cmd([[
autocmd BufReadPost *
   \ if line("'\"") > 0 && line("'\"") <= line("$") |
   \   exe "normal! g`\"" |
   \ endif
]])

-- Other useful mappings
vim.cmd([[
" find all tailing whitespace
nnoremap <leader>w /\v\s+$<CR>
" delete all tailing whitespace
nnoremap <leader>W :%s/\v\s+$//g \| noh<CR>

" copy current file name (relative/absolute) to system clipboard (Linux version)
if has("gui_gtk") || has("gui_gtk2") || has("gui_gnome") || has("unix")
  " relative path (src/foo.txt)
  nnoremap <leader>cf :let @+=expand("%")<CR>

  " absolute path (/something/src/foo.txt)
  nnoremap <leader>cF :let @+=expand("%:p")<CR>

  " filename (foo.txt)
  nnoremap <leader>ct :let @+=expand("%:t")<CR>

  " directory name (/something/src)
  nnoremap <leader>ch :let @+=expand("%:p:h")<CR>

  " filename:linenumber (foo.txt:42)
  nnoremap <leader>cg :let @+=expand("%:t") . ":" . line(".")<CR>
endif


" options for vim-translator
let g:translator_default_engines = [ 'google' ]
" Display translation in a window
nnoremap <silent> <leader>ts <Plug>TranslateW
vnoremap <silent> <leader>ts <Plug>TranslateWV
]])

if vim.fn.has("win32") == 1 then
  -- To fix the error: '"C:\Program Files\Git\usr\bin\bash.exe"' is not executable
  vim.opt.shell = "C:\\Program Files\\Git\\bin\\bash.exe"
end

