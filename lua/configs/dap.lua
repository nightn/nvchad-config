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
-- C / C++ reverse debugging: rr + GDB via cpptools (OpenDebugAD7)
-- ──────────────────────────────────────────────────────────────────────────────
-- Why cpptools instead of GDB's native DAP mode?
--   GDB 14+ added --interpreter=dap, but Ubuntu 22.04 ships GDB 12.
--   cpptools (Microsoft's OpenDebugAD7) works with GDB 8+ and natively
--   implements the DAP reverseContinue / stepBack requests, which map to
--   GDB's reverse-continue / step-back commands that rr provides.
--
-- Workflow:
--   1. Record once : rr record ./my_program [args]
--   2. Replay      : <leader>rr  (starts rr and connects GDB via cpptools)
--   3. Debug       : use normal step/continue keys; reverse with <leader>rc / <leader>rs

local cpptools_path = vim.fn.stdpath("data")
  .. "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7"

dap.adapters.cppdbg = {
  id      = "cppdbg",  -- tells OpenDebugAD7 to load cppdbg.ad7Engine.json (must match the file on disk)
  type    = "executable",
  command = cpptools_path,
  options = { detached = false },
}

-- GDB 14+ native DAP adapter (--interpreter=dap was added in GDB 14.0)
-- Used as an alternative backend for rr when GDB 14+ is available.
--
-- CRITICAL: non-stop settings MUST be passed via --iex (before DAP starts),
-- NOT via initCommands (which is a cpptools extension that GDB ignores).
-- Both "set non-stop off" and "maintenance set target-non-stop off" are needed
-- before the remote target connects, otherwise rr reverse commands fail with
-- "Target multi-thread does not support this command".
--
-- CRITICAL: for rr, use DAP request = "attach" (not "launch").
-- "launch" runs GDB's "run" command which is wrong for remote targets.
-- "attach" with `target` runs "target remote <target>" which is correct for rr.
dap.adapters.gdb_rr = function(cb, config)
  -- Dynamically build the adapter so we can embed the correct rr port
  cb({
    type    = "executable",
    command = "gdb",
    args    = {
      "--interpreter=dap",
      "--iex", "set non-stop off",
      "--iex", "maintenance set target-non-stop off",
      "--iex", "set sysroot /",
      "--iex", "set remotetimeout 10000",
    },
  })
end

-- ──────────────────────────────────────────────────────────────────────────────
-- JavaScript / TypeScript: vscode-js-debug (js-debug-adapter via Mason)
-- ──────────────────────────────────────────────────────────────────────────────

local js_debug_path = vim.fn.stdpath("data")
  .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

-- pwa-node: debug Node.js scripts and server processes
dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = { command = "node", args = { js_debug_path, "${port}" } },
}

-- pwa-chrome: debug browser apps (Chrome must be launched with --remote-debugging-port)
dap.adapters["pwa-chrome"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = { command = "node", args = { js_debug_path, "${port}" } },
}

local js_configs = {
  {
    type    = "pwa-node",
    request = "launch",
    name    = "Launch file (Node)",
    program = "${file}",
    cwd     = "${workspaceFolder}",
    -- Source maps let you debug TypeScript at the .ts source level
    sourceMaps = true,
    resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
  },
  {
    type      = "pwa-node",
    request   = "attach",
    name      = "Attach to Node process",
    processId = require("dap.utils").pick_process,
    cwd       = "${workspaceFolder}",
    sourceMaps = true,
  },
  {
    type    = "pwa-chrome",
    request = "launch",
    name    = "Launch Chrome",
    url     = function()
      return vim.fn.input("URL: ", "http://localhost:3000")
    end,
    webRoot    = "${workspaceFolder}",
    sourceMaps = true,
  },
}

for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
  dap.configurations[lang] = js_configs
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Bash: bash-debug-adapter (wraps bashdb) via Mason
-- ──────────────────────────────────────────────────────────────────────────────

local bash_debug_path = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter"

dap.adapters.bashdb = {
  type    = "executable",
  command = bash_debug_path .. "/bash-debug-adapter",
  name    = "bashdb",
}

dap.configurations.sh = {
  {
    type              = "bashdb",
    request           = "launch",
    name              = "Launch bash script",
    showDebugOutput   = true,
    pathBashdb        = bash_debug_path .. "/extension/bashdb_dir/bashdb",
    -- Correct field names as per bash-debug-adapter spec:
    --   pathBashdbLib (not bashdbLibLocation)
    -- terminalKind = "debugConsole" uses internal spawn; "integrated" would
    -- send a runInTerminal DAP request which nvim-dap does not handle.
    pathBashdbLib     = bash_debug_path .. "/extension/bashdb_dir",
    trace             = true,
    file              = "${file}",
    program           = "${file}",
    cwd               = "${workspaceFolder}",
    pathCat           = "cat",
    pathBash          = "/bin/bash",
    pathMkfifo        = "mkfifo",
    pathPkill         = "pkill",
    args              = {},
    argsString        = "",
    env               = {},
    terminalKind      = "debugConsole",
  },
}


-- ──────────────────────────────────────────────────────────────────────────────

-- Automatically open the UI when a debug session initialises
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end

-- Patch capabilities for GDB+rr sessions.
-- GDB's DAP layer does not advertise supportsReverseContinue / supportsStepBack
-- statically because whether reverse execution is available depends on the
-- target (rr), not on GDB itself. Without this patch nvim-dap would refuse to
-- send any reverse requests.
dap.listeners.after.event_initialized["rr_reverse_caps"] = function(session)
  if session.config and session.config.type == "gdb_rr" then
    session.capabilities.supportsReverseContinue = true
    session.capabilities.supportsStepBack        = true
  end
end

-- Auto-continue past the initial attach stop in rr sessions.
-- When GDB connects via `target remote`, rr positions at the very first
-- instruction of the replay which is inside ld.so (the dynamic linker) — a
-- frame with no source. nvim-dap would show a "Source missing" warning.
-- This one-shot listener fires on the first stopped event for gdb_rr sessions
-- and immediately continues to the user's first breakpoint.
dap.listeners.after.event_initialized["rr_skip_initial_stop_setup"] = function(session)
  if not session.config or session.config.type ~= "gdb_rr" then return end

  local key = "rr_skip_initial_stop_" .. tostring(session.id or math.random())
  dap.listeners.after.event_stopped[key] = function(s, body)
    if s ~= session then return end
    -- Deregister immediately — this listener is one-shot
    dap.listeners.after.event_stopped[key] = nil
    if body and body.reason == "attach" then
      vim.schedule(function()
        if dap.session() == session then
          dap.continue()
        end
      end)
    end
  end
end

-- Automatically close the UI when the session ends (either terminated or exited)
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- ──────────────────────────────────────────────────────────────────────────────
-- rr helper (exported so mappings.lua can call it)
-- ──────────────────────────────────────────────────────────────────────────────

local RR_PORT   = 45678
local rr_job_id = nil    -- tracks the active rr replay background job

-- Return the major version of the system GDB, or nil if it cannot be determined
local function gdb_major_version()
  local out = vim.fn.system("gdb --version 2>/dev/null")
  return tonumber(out:match("GNU gdb%s+%S-%s*(%d+)%.") or out:match("GNU gdb %(.-%)%s+(%d+)%."))
end

-- Start rr replay in server mode; kill any previous rr job first.
-- Returns true on success, false on failure.
local function launch_rr_server()
  if rr_job_id and rr_job_id > 0 then
    vim.fn.jobstop(rr_job_id)
    rr_job_id = nil
  end

  rr_job_id = vim.fn.jobstart({ "rr", "replay", "-s", tostring(RR_PORT) }, {
    on_exit = function() rr_job_id = nil end,
  })

  if rr_job_id <= 0 then
    vim.notify(
      "Failed to start rr replay. Is rr installed and is there a recording in ~/.local/share/rr?",
      vim.log.levels.ERROR
    )
    return false
  end

  vim.notify(
    string.format("rr replay listening on :%d…", RR_PORT),
    vim.log.levels.INFO
  )
  return true
end

-- Find the mmap_hardlink binary that rr stores alongside the trace.
-- rr copies the binary into the trace dir so that symbols remain valid even
-- if the original file is rebuilt.  The DAP `attach` request passes this path
-- as the `program` field so GDB loads the correct symbol table.
local function find_rr_program(executable)
  -- rr names the hardlink "mmap_hardlink_<N>_<basename>"
  local basename = vim.fn.fnamemodify(executable, ":t")
  -- latest-trace is a symlink to the most recent recording
  local trace_dir = vim.fn.expand("~/.local/share/rr/latest-trace")
  local out = vim.fn.systemlist(string.format("ls %s/mmap_hardlink_*_%s 2>/dev/null", trace_dir, basename))
  if out and #out > 0 then
    return out[#out]  -- pick the last one if multiple exist
  end
  -- Fallback: use the original executable (symbols may differ if rebuilt)
  return executable
end

local M = {}

-- Start an rr replay session and connect GDB (via DAP) to it.
-- Prompts for the executable, then lets the user pick the backend.
-- Prerequisite: `rr record ./my_program [args]` must have been run beforehand.
M.start_rr_debug = function()
  local executable = vim.fn.input("Executable (for rr replay): ", vim.fn.getcwd() .. "/", "file")
  if executable == "" then return end

  vim.ui.select(
    {
      "cpptools  — GDB 8+  (always works, uses Microsoft OpenDebugAD7)",
      "GDB 14+   — native DAP mode  (faster UI, requires GDB ≥ 14)",
    },
    { prompt = "rr backend:" },
    function(choice)
      if not choice then return end

      if choice:find("GDB 14+") then
        -- ── GDB 14+ native DAP ─────────────────────────────────────────────
        -- Key lessons from debugging:
        --   1. "set non-stop off" + "maintenance set target-non-stop off" MUST
        --      come via GDB --iex flags (before DAP starts), not initCommands.
        --      initCommands is a cpptools extension; GDB's own DAP ignores it.
        --   2. Use request = "attach" with `target`, NOT request = "launch".
        --      "launch" runs GDB's `run` command which restarts / is wrong for
        --      remote targets. "attach" with `target` runs `target remote <t>`.
        --   3. rr's mmap_hardlink binary must be used as `program` so that GDB
        --      loads the same symbol table the recording was made with.

        local ver = gdb_major_version()
        if not ver or ver < 14 then
          vim.notify(
            string.format(
              "GDB 14+ required for native DAP mode, found GDB %s.\n"
                .. "Install via: sudo add-apt-repository ppa:ubuntu-toolchain-r/test && sudo apt install gdb",
              ver or "unknown"
            ),
            vim.log.levels.ERROR
          )
          return
        end

        if not launch_rr_server() then return end

        vim.defer_fn(function()
          dap.run({
            name    = "rr replay (GDB 14+)",
            type    = "gdb_rr",
            -- "attach" with `target` → GDB runs: target remote localhost:PORT
            -- This is the correct way to connect to rr's gdbserver stub.
            request = "attach",
            program = find_rr_program(executable),
            target  = string.format("localhost:%d", RR_PORT),
          })
        end, 500)  -- give rr ~500 ms to start listening

      else
        -- ── cpptools / OpenDebugAD7 (GDB 8+) ──────────────────────────────
        if not launch_rr_server() then return end

        vim.defer_fn(function()
          dap.run({
            name    = "rr replay (cpptools)",
            type    = "cppdbg",
            request = "launch",
            program = executable,
            cwd     = vim.fn.getcwd(),
            miDebuggerServerAddress = string.format("localhost:%d", RR_PORT),
            useExtendedRemote       = true,
            setupCommands = {
              { text = "set non-stop off",        ignoreFailures = false, description = "Required by rr" },
              { text = "-enable-pretty-printing", ignoreFailures = true,  description = "GDB pretty printing" },
            },
          })
        end, 500)
      end
    end
  )
end

return M
