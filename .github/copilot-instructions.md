# Neovim Config (NvChad-based)

## Architecture

This config is layered on top of **NvChad v2.5** (`NvChad/NvChad`, branch `v2.5`). NvChad provides the base plugin set, UI framework, and default mappings. This repo only defines overrides and additions on top of that.

- `init.lua` — entry point: bootstraps lazy.nvim, loads NvChad + custom plugins, registers autocmds and mappings
- `lua/chadrc.lua` — NvChad UI config (theme, statusline, tabufline, nvdash); must follow the structure of [nvconfig.lua](https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua)
- `lua/plugins/init.lua` — custom plugin definitions (extend/override NvChad defaults)
- `lua/configs/` — per-plugin config files: `lspconfig.lua`, `conform.lua`, `luasnip.lua`, `lazy.lua`
- `lua/mappings.lua` — custom keymaps layered on top of `nvchad.mappings`
- `lua/themes/darcula.lua` — custom base46 theme (dark, JetBrains Darcula-inspired)
- `ftdetect/torque.vim` — filetype detection for Torque files
- `syntax/torque.vim` — syntax highlighting for Torque files

## Plugin Manager

[lazy.nvim](https://github.com/folke/lazy.nvim) (auto-bootstrapped). After first install, run `:MasonInstallAll` to install all LSP servers and tools.

To update plugins: `:Lazy sync`

## LSP Servers (via Mason + nvim-lspconfig)

Configured in `lua/configs/lspconfig.lua` using `vim.lsp.config` + `vim.lsp.enable` (Neovim 0.11+ API):

| Server | Language |
|---|---|
| clangd | C/C++ (with custom `--query-driver` for cross-compilation) |
| html / cssls | HTML / CSS |
| ts_ls | TypeScript/JavaScript |
| jedi_language_server | Python |
| cmake | CMake |
| bashls | Bash |
| gn_language_server | GN build system |
| vue_ls | Vue (requires `npm install -g @vue/language-server`) |
| sourcekit | Swift / Objective-C (filetypes restricted to exclude c/cpp) |

The `custom_clangd_query_driver` path in `lspconfig.lua` points to a local ARM64 toolchain — update this for your environment.

## Formatters (conform.nvim)

Configured in `lua/configs/conform.lua`. Format on save is **disabled by default** (commented out). Trigger manually with `<leader>fm`.

| Filetype | Formatter | Notes |
|---|---|---|
| lua | stylua | 2-space indent, Spaces (not tabs) |
| js/ts | prettierd / prettier | single quotes forced |
| cpp / c | clang-format | |
| python | isort → black | |
| html | prettierd / prettier | |

## Key Mappings

Custom mappings are defined in `lua/mappings.lua` on top of NvChad defaults. Notable additions:

| Key | Action |
|---|---|
| `jk` | Exit insert mode |
| `H` / `L` | Previous / next buffer |
| `<C-h/j/k/l>` | Window navigation (works in terminal mode too) |
| `<leader>gt` | Go to definition (Telescope) |
| `<leader>gr` | Go to references (Telescope) |
| `<leader>fw` | Find symbols in workspace |
| `<leader>fg` | Live grep (requires ripgrep) |
| `<leader>ld` | List diagnostics |
| `<leader>rn` | LSP rename |
| `<leader>fi` | LSP code action (fix) |
| `<leader>nv` | Navbuddy (symbol tree navigation) |
| `<leader>fm` | Format (also works in visual mode for range format) |
| `<leader>cf/cF/ct/ch` | Copy relative path / absolute path / filename / directory |
| `<leader>cj` | Copy relative path (Lua implementation) |
| `<leader>cg` | Copy `filename:linenumber` (useful for GDB breakpoints) |
| `<leader>w` / `<leader>W` | Find / delete trailing whitespace |
| `<leader>ts` | Translate selection/word (vim-translator, Google) |
| `<leader>cc` | Toggle CopilotChat |
| `<C-\`` >` | Toggle horizontal terminal |
| `<A-j>` / `<A-l>` | Toggle horizontal / vertical terminal |
| `<leader>gb` / `<leader>gB` | Git blame line / file |
| `]c` / `[c` | Next / prev git hunk |

**Disabled NvChad defaults:** `<S-tab>`, `<tab>` (conflicts with `<C-i>`), `<leader>n`, `<A-v>`, `<A-h>`

## File Type Associations

Defined in `init.lua` via autocmds:
- `.def`, `.inc` → `cpp`
- `.bt` → `c`

## Theme

Active theme: **darcula** (defined in `lua/themes/darcula.lua`). Toggle with `<leader>th`. Theme toggle pair: `darcula` ↔ `github_light`.

To add a custom theme, place it in `lua/themes/<name>.lua` following the base46 structure, then reference it in `chadrc.lua`.

## Conventions

- Plugin configs go in `lua/configs/<plugin-name>.lua` and are `require`d from `lua/plugins/init.lua`
- Additional plugin spec files can be added under `lua/plugins/` — they are auto-imported via `{ import = "plugins" }`
- `lua/options.lua` extends NvChad options (currently minimal)
- Local per-project config is enabled via `vim.opt.exrc = true` (`.nvimrc` / `.exrc` in project root)
- Windows compatibility: shell is set to Git bash when `has("win32")`

## DAP (C/C++ Debugging)

Configured in `lua/plugins/dap.lua` and `lua/configs/dap.lua`. Loads on `event = "VeryLazy"`.

**Adapter:** codelldb (Mason-managed, LLDB-based). Path: `$NVIM_DATA/mason/packages/codelldb/extension/adapter/codelldb`

**Launch configs** (selected via `<F5>`/`<leader>dc`):
- *Launch* — prompts for executable path and CLI args
- *Attach* — fuzzy-picks a running process by PID

**Languages supported:**
- **C/C++** — codelldb (regular), cpptools/GDB (rr reverse debugging)
- **JavaScript/TypeScript** — vscode-js-debug (`pwa-node` for Node, `pwa-chrome` for browser)
- **Bash** — bash-debug-adapter (wraps bashdb)

**Key bindings:**

| Key | Action |
|---|---|
| `<leader>bb` | Toggle breakpoint |
| `<leader>B` | Set conditional breakpoint |
| `<leader>dd` | Focus current stopped frame + center view |
| `<leader>k` | **Context-aware**: evaluate expr/selection (DAP active) OR diagnostic float |
| `<leader>du` | Toggle DAP UI |
| `<leader>bt` | Backtrace / call stack (Telescope) |
| `<leader>bl` | List all breakpoints (Telescope) |
| `<leader>dp` | Browse DAP commands (Telescope) |
| `<leader>R` | Run to cursor |
| `<F5>` / `<leader>dc` | Continue |
| `<F10>` / `<leader>dn` | Step over |
| `<F11>` / `<leader>di` | Step into |
| `<F12>` / `<leader>do` | Step out |
| `<leader>rr` | Start rr reverse-debug session |
| `<leader>rc` | rr reverse-continue |
| `<leader>rs` | rr reverse-step (into) |
| `<leader>rN` | rr reverse-next (over) |
| `<leader>dq` | Terminate session |

**UI** auto-opens on session start and auto-closes on termination. `<leader>du` is a manual override.

**rr protocol notes** (hard-won, do not change without testing):
- `set non-stop off` + `maintenance set target-non-stop off` MUST be passed via GDB `--iex` flags (before DAP starts), NOT via `initCommands` — `initCommands` is a cpptools extension that GDB's native DAP ignores entirely.
- For GDB 14+ backend, use DAP `request = "attach"` with a `target` field (→ GDB runs `target remote <target>`). Using `request = "launch"` runs GDB's `run` command which is wrong for remote targets.
- Reverse commands (`reverse-continue`, `reverse-next`, `reverse-step`) are sent via DAP `evaluate` with `context = "repl"` because GDB 14–17's DAP layer does not implement the `reverseContinue`/`stepBack` DAP requests — but the GDB console commands work reliably through rr.
- The `gdb_rr` adapter type is used (not `gdb`) to allow targeted capability patching in the `event_initialized` listener.

