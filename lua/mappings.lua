require("nvchad.mappings")

-- disable mappings

local nomap = vim.keymap.del

-- <S-tab> will affect the function of <C-i>, disable it
nomap("n", "<S-tab>")
nomap("n", "<tab>")
nomap("n", "<leader>n")

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- basic
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })

-- buffer
map("n", "H", "<cmd> bp <CR>", { desc = "Previous buffer" })
map("n", "L", "<cmd> bn <CR>", { desc = "Next buffer" })

-- window
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "window left" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "window right" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "window down" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "window up" })

-- lsp
map("n", "<leader>gt", "<cmd> Telescope lsp_definitions <CR>", { desc = "Goto definitions" })
map("n", "<leader>fw", "<cmd> Telescope lsp_dynamic_workspace_symbols <CR>", { desc = "Find symbols in workspace" })
map("n", "<leader>fg", "<cmd> Telescope live_grep <CR>", { desc = "Live grep" })
map("n", "<leader>ld", "<cmd> Telescope diagnostics <CR>", { desc = "List diagnostics" })
map("n", "<C-p>", "<cmd> Telescope keymaps <CR>", { desc = "Telescope keymaps" })

-- Support format in virtual mode
map("v", "<leader>fm", function()
  require("conform").format({ lsp_fallback = true })
  -- Leave visual mode after range format
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end, { desc = "general format file" })

map("n", "<leader>gr", function()
  require("telescope.builtin").lsp_references()
end, { desc = "Goto references" })

map("n", "<leader>rn", function()
  require("nvchad.lsp.renamer")()
end, { desc = "LSP rename" })

map("n", "<leader>fi", function()
  vim.lsp.buf.code_action({ apply = true })
end, { desc = "LSP fix current" })

map("n", "<leader>nv", function()
  require("nvim-navbuddy")
  vim.cmd("Navbuddy")
end, { desc = "Navbuddy" })

-- terminal
-- [Attention] <C-`> does not work in tabby or windows terminal
map({ "n", "t" }, "<C-`>", function()
  require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm" })
end, { desc = "terminal toggleable horizontal term" })

-- git
map("n", "<leader>hu", function()
  require("gitsigns").reset_hunk()
end, { desc = "Hunk undo" })

map("n", "<leader>hp", function()
  require("gitsigns").preview_hunk()
end, { desc = "Hunk preview" })

map("n", "<leader>gb", "<cmd> Git blame_line <CR>", { desc = "Git blame_line" })
map("n", "<leader>gB", "<cmd> Git blame <CR>", { desc = "Git blame" })

map("n", "]c", function()
  if vim.wo.diff then
    return "]c"
  end
  vim.schedule(function()
    require("gitsigns").next_hunk()
  end)
  return "<Ignore>"
end, { desc = "Jump to next hunk" })

map("n", "[c", function()
  if vim.wo.diff then
    return "[c"
  end
  vim.schedule(function()
    require("gitsigns").prev_hunk()
  end)
  return "<Ignore>"
end, { desc = "Jump to prev hunk" })

-- syntax
map(
  "n",
  "<leader>a",
  "<cmd> TSHighlightCapturesUnderCursor <CR>",
  { desc = "TSHighlightCapturesUnderCursor (from nvim-treesitter/playground)" }
)
