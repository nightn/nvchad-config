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
local function nt2t()
  -- switch 'nt' mode to 't' mode
  if vim.api.nvim_get_mode().mode == "nt" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>i", true, true, true), "t", true)
  end
end

map({ "n", "t" }, "<C-h>", function()
  vim.api.nvim_command("wincmd h")
  nt2t()
end, { desc = "switch window left" })

map({ "n", "t" }, "<C-l>", function()
  vim.api.nvim_command("wincmd l")
  nt2t()
end, { desc = "switch window right" })

map({ "n", "t" }, "<C-j>", function()
  vim.api.nvim_command("wincmd j")
  nt2t()
end, { desc = "switch window down" })

map({ "n", "t" }, "<C-k>", function()
  vim.api.nvim_command("wincmd k")
  nt2t()
end, { desc = "switch window up" })

-- lsp
map("n", "<leader>gt", "<cmd> Telescope lsp_definitions <CR>", { desc = "Goto definitions" })
map("n", "<leader>fw", "<cmd> Telescope lsp_dynamic_workspace_symbols <CR>", { desc = "Find symbols in workspace" })
map("n", "<leader>fg", "<cmd> Telescope live_grep <CR>", { desc = "Live grep" })
map("n", "<leader>ld", "<cmd> Telescope diagnostics <CR>", { desc = "List diagnostics" })
map("n", "<C-p>", "<cmd> Telescope keymaps <CR>", { desc = "Telescope keymaps" })
-- When a DAP session is active: evaluate expression under cursor or visual selection.
-- Otherwise: fall back to the standard diagnostic float.
map({ "n", "v" }, "<leader>k", function()
  if require("dap").session() then
    require("dapui").eval()
  else
    vim.diagnostic.open_float()
  end
end, { desc = "DAP eval expr / Diagnostic float" })

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

-- toggleable
nomap({ "n", "t" }, "<A-v>")
map({ "n", "t" }, "<A-l>", function()
  require("nvchad.term").toggle({ pos = "vsp", id = "vtoggleTerm" })
end, { desc = "terminal toggleable vertical term" })

nomap({ "n", "t" }, "<A-h>")
map({ "n", "t" }, "<A-j>", function()
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

-- copy relative path
map("n", "<leader>cj", function()
  local current_file = vim.fn.expand("%:p")
  local current_dir = vim.fn.getcwd()

  -- 确保路径以 / 结尾以便正确匹配
  if not current_dir:match("/$") then
    current_dir = current_dir .. "/"
  end

  -- 计算相对路径
  local relative_path = current_file:gsub("^" .. vim.pesc(current_dir), "")

  -- 复制到系统剪贴板
  if vim.fn.has("clipboard") == 1 then
    vim.fn.setreg("+", relative_path)
    vim.notify("已复制相对路径: " .. relative_path, vim.log.levels.INFO)
  else
    -- 如果没有剪贴板支持，复制到 vim 寄存器
    vim.fn.setreg('"', relative_path)
    vim.notify("已复制相对路径到 vim 寄存器: " .. relative_path, vim.log.levels.WARN)
  end
end, { desc = "Copy relative path to clipboard" })

-- syntax
map(
  "n",
  "<leader>sy",
  "<cmd> TSHighlightCapturesUnderCursor <CR>",
  { desc = "TSHighlightCapturesUnderCursor (from nvim-treesitter/playground)" }
)

-- Github Copilot
map("n", "<leader>cc", "<cmd> CopilotChatToggle <CR>", { desc = "Toggle copilot chat" })

-- ──────────────────────────────────────────────────────────────────────────────
-- DAP (Debug Adapter Protocol) — C/C++ debugging with codelldb
-- ──────────────────────────────────────────────────────────────────────────────

-- Breakpoints ----------------------------------------------------------------

-- Toggle a regular breakpoint on the current line
map("n", "<leader>bb", function()
  require("dap").toggle_breakpoint()
end, { desc = "DAP toggle breakpoint" })

-- Set a conditional breakpoint (prompts for a boolean expression)
map("n", "<leader>B", function()
  require("dap").set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "DAP set conditional breakpoint" })

-- Execution control ----------------------------------------------------------

-- F-key bindings follow the Visual Studio / IntelliJ convention that most
-- debugger users are already familiar with.
map("n", "<F5>",  function() require("dap").continue()   end, { desc = "DAP continue" })
map("n", "<F10>", function() require("dap").step_over()  end, { desc = "DAP step over" })
map("n", "<F11>", function() require("dap").step_into()  end, { desc = "DAP step into" })
map("n", "<F12>", function() require("dap").step_out()   end, { desc = "DAP step out" })

-- <leader>d* alternatives for terminals where F-keys are unreliable
map("n", "<leader>dc", function() require("dap").continue()      end, { desc = "DAP continue" })
map("n", "<leader>dn", function() require("dap").step_over()     end, { desc = "DAP step over (next)" })
map("n", "<leader>di", function() require("dap").step_into()     end, { desc = "DAP step into" })
map("n", "<leader>do", function() require("dap").step_out()      end, { desc = "DAP step out" })
map("n", "<leader>dq", function() require("dap").terminate()     end, { desc = "DAP terminate session" })

-- Jump to the line where execution is currently paused, then center the view
map("n", "<leader>R", function() require("dap").run_to_cursor() end, { desc = "DAP run to cursor" })

-- Navigate to the current stopped frame and center the view (like zz)
map("n", "<leader>dd", function()
  local session = require("dap").session()
  if not session then
    vim.notify("No active DAP session", vim.log.levels.WARN)
    return
  end
  require("dap").focus_frame()
  -- Schedule the center so the cursor has time to land on the target line first
  vim.schedule(function()
    vim.cmd("normal! zz")
  end)
end, { desc = "DAP focus current frame (center)" })

-- UI -------------------------------------------------------------------------

-- Toggle the dapui side panels (manual override for the auto-open behaviour)
map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "DAP toggle UI" })

-- Telescope pickers ----------------------------------------------------------

-- Call stack / backtrace for the current thread
map("n", "<leader>bt", function()
  require("telescope").extensions.dap.frames()
end, { desc = "DAP backtrace (Telescope)" })

-- All breakpoints across every file
map("n", "<leader>bl", function()
  require("telescope").extensions.dap.list_breakpoints()
end, { desc = "DAP list breakpoints (Telescope)" })

-- Browse and run any DAP command
map("n", "<leader>dp", function()
  require("telescope").extensions.dap.commands()
end, { desc = "DAP commands (Telescope)" })
