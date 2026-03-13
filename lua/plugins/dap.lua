return {
  {
    "mfussenegger/nvim-dap",
    -- Load after the UI is ready so all DAP keymaps work without delay
    event = "VeryLazy",
    dependencies = {
      -- UI panels: variables, watches, call stack, breakpoints, console
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          require("dapui").setup()
        end,
      },

      -- Inline virtual text showing variable values at the current line
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },

      -- Telescope pickers for DAP: frames, breakpoints, commands
      {
        "nvim-telescope/telescope-dap.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = function()
          require("telescope").load_extension("dap")
        end,
      },
    },

    config = function()
      require("configs.dap")
    end,
  },
}
