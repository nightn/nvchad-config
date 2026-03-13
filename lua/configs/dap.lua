local dap = require("dap")
local dapui = require("dapui")

-- ──────────────────────────────────────────────────────────────────────────────
-- Signs
-- ──────────────────────────────────────────────────────────────────────────────
local dap_breakpoint_color_dark = {
  breakpoint = {
    ctermbg = 0,
    bg = '#372423',
  },
  breakpoint_icon = {
    ctermbg = 0,
    fg = '#b95b54',
  },
  logpoint = {
    ctermbg = 0,
    bg = '#372423',
  },
  stopped = {
    ctermbg = 0,
    bg = '#396095',
    -- fg = '#ffffff'
  },
  stopped_icon = {
    ctermbg = 0,
    fg = '#e6a94c',
  },
}

local dap_breakpoint_color_light = {
  breakpoint = {
    ctermbg = 0,
    bg = '#f7eae7',
  },
  breakpoint_icon = {
    ctermbg = 0,
    fg = '#cc6063',
  },
  logpoint = {
    ctermbg = 0,
    bg = '#f7eae7',
  },
  stopped = {
    ctermbg = 0,
    bg = '#2d55a0',
    fg = '#ffffff'
  },
  stopped_icon = {
    ctermbg = 0,
    fg = '#e2a439',
  },
}

local dap_breakpoint_color = nil

if vim.o.background == 'dark' then
  dap_breakpoint_color = dap_breakpoint_color_dark
else
  dap_breakpoint_color = dap_breakpoint_color_light
end

vim.api.nvim_set_hl(0, 'DapBreakpoint', dap_breakpoint_color.breakpoint)
vim.api.nvim_set_hl(0, 'DapBreakpointIcon', dap_breakpoint_color.breakpoint_icon)
vim.api.nvim_set_hl(0, 'DapLogPoint', dap_breakpoint_color.logpoint)
vim.api.nvim_set_hl(0, 'DapStopped', dap_breakpoint_color.stopped)
vim.api.nvim_set_hl(0, 'DapStoppedIcon', dap_breakpoint_color.stopped_icon)

local dap_breakpoint = {
  error = {
    text = '',
    texthl = 'DapBreakpointIcon',
    linehl = 'DapBreakpoint',
  },
  condition = {
    text = '',
    texthl = 'DapBreakpointIcon',
    linehl = 'DapBreakpoint',
  },
  rejected = {
    text = "",
    texthl = 'DapBreakpintIcon',
    linehl = 'DapBreakpoint',
  },
  logpoint = {
    text = '',
    texthl = 'DapLogPointIcon',
    linehl = 'DapLogPoint',
  },
  stopped = {
    text = '',
    texthl = 'DapStoppedIcon',
    linehl = 'DapStopped',
  },
}

vim.fn.sign_define('DapBreakpoint', dap_breakpoint.error)
vim.fn.sign_define('DapBreakpointCondition', dap_breakpoint.condition)
vim.fn.sign_define('DapBreakpointRejected', dap_breakpoint.rejected)
vim.fn.sign_define('DapLogPoint', dap_breakpoint.logpoint)
vim.fn.sign_define('DapStopped', dap_breakpoint.stopped)

-- ──────────────────────────────────────────────────────────────────────────────
-- Adapters
-- ──────────────────────────────────────────────────────────────────────────────

-- codelldb is a high-quality LLDB-based adapter for C/C++/Rust; installed via Mason
local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = codelldb_path,
    args = { "--port", "${port}" },
  },
}

-- ──────────────────────────────────────────────────────────────────────────────
-- Launch configurations
-- ──────────────────────────────────────────────────────────────────────────────

-- Interactively asks for the executable path at launch time
local function input_program()
  return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
end

-- Interactively asks for command-line args (space-separated) at launch time
local function input_args()
  local raw = vim.fn.input("Args (space-separated): ")
  return vim.split(raw, " ", { trimempty = true })
end

dap.configurations.cpp = {
  {
    name        = "Launch (codelldb)",
    type        = "codelldb",
    request     = "launch",
    program     = input_program,
    cwd         = "${workspaceFolder}",
    args        = input_args,
    stopOnEntry = false,
  },
  {
    -- Attach to an already-running process; shows a fuzzy picker for the PID
    name    = "Attach to process",
    type    = "codelldb",
    request = "attach",
    pid     = require("dap.utils").pick_process,
    cwd     = "${workspaceFolder}",
  },
}

-- C reuses C++ configurations (codelldb handles both)
dap.configurations.c = dap.configurations.cpp

-- ──────────────────────────────────────────────────────────────────────────────
-- Auto open / close UI
-- ──────────────────────────────────────────────────────────────────────────────

-- Automatically open the UI when a debug session initialises
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end

-- Automatically close the UI when the session ends (either terminated or exited)
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
