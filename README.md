# nvchad-config

## install

```sh
# linux/macos
git clone https://github.com/nightn/nvchad-config.git ~/.config/nvim && nvim

# windows (PowerShell)
git clone https://github.com/nightn/nvchad-config.git $ENV:USERPROFILE\AppData\Local\nvim && nvim
```
Run `:MasonInstallAll` command after lazy.nvim finishes downloading plugins.

## dependencies

(1) ripgrep for "<leader>fg".

```sh
# linux
sudo apt install ripgrep
# windows
# download release package from: https://github.com/BurntSushi/ripgrep
```

(2) Font

Nerd Font as your terminal font.
Make sure the nerd font you set doesn't end with Mono to prevent small icons.
Example : `JetbrainsMono Nerd Font` and not `JetbrainsMono Nerd Font Mono`
Adviced font: `FiraCode Nerd Font`

## update

`Lazy sync` command

## enhancements

(0) add lots of mappings.

- `<leader>rn` : lsp rename.

- `[c`, `]c` : hunk navigation.

- `<leader>cg` : copy "<filename>:<linenumber>", this is very useful when setting breakpoint in gdb.

- `<leader>w`, `<leader>W` : find/delete all tailing whitespace.

- `<leader>ts` : translation.

- `<leader>a` : shows any treesitter or syntax highlight groups under the cursor.

(1) support "<leader>nv".

(2) nvim-cmp custom config: do not preselect the first one.

(3) remember last location (by vim.cmd).

(4) custom ui:
- set statusline.separator_style to "round";
- set tabufline.lazyload to false.
- set nvdash.load_on_startup to true.

(5) add new theme: darcula.

- Fix highlight for `Search`.

(6) Add lots of Mason and nvim-treesitter ensure-installed config.

(7) add more plugins.

- `voldikss/vim-translator` : translation plugin.

- `google/vim-searchindex` : show complete count of searching matches.

- `nvim-treesitter/playground` : for using cmd: TSHighlightCapturesUnderCursor.

## tree-sitter

### swift

`TSInstall swift` will throw error: tree-sitter CLI is needed because `swift` is marked that it needs to be generated from the grammar definitions to be compatible with nvim!

Solution: download tree-sitter release from here (https://github.com/tree-sitter/tree-sitter) and then add it to PATH

Attention: swift tree-sitter plugin is too slow, so disable it by default.

## LSP

### sourcekit

lspconfig.sourcekit will try to loop up `sourcekit-lsp` in PATH. see [here](https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/sourcekit.lua).

you can install swift from here (https://www.swift.org/install) and add it to PATH.

