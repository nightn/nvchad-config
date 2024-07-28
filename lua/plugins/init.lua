return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- default lsp
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettier",
        -- more lsp
        "clangd", -- C/C++
        "typescript-language-server", -- JavaScript/TypeScript
        "cmake-language-server", -- cmake
        "bash-language-server", -- bash
        "jedi-language-server", -- python
        "clang-format",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "c",
        "cpp",
        "java",
        "python",
        "cmake",
        "bash",
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    opts = {
      completion = {
        completeopt = "menu,menuone,noinsert,noselect",  -- do not preselect the first one
      },
    }
  },


  {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim"
    },
    opts = {
      lsp = { auto_attach = true },
      window = {
        size = "90%",
        sections = {
          left = {
            size = "15%",
          },
          mid = {
            size = "25%"
          },
        }
      }
    }
  },
}
