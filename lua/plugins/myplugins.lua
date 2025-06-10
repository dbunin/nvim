local overrides = require "configs.configs.overrides"

---@type NvPluginSpec[]
local plugins = {
  -- Override plugin definition options
  { "lukas-reineke/indent-blankline.nvim", enabled = true },
  { "folke/which-key.nvim", enabled = true },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "lukas-reineke/lsp-format.nvim",
      "rcarriga/nvim-notify",
      {
        "RRethy/vim-illuminate",
        config = function()
          require("illuminate").configure {
            providers = { "lsp" },
          }
          vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
          vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
          vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })
        end,
      },
    },
    config = function()
      -- require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  {
    "creativenull/efmls-configs-nvim",
    version = "v1.x.x", -- version is optional, but recommended
    dependencies = { "neovim/nvim-lspconfig" },
  },
  -- overrde plugin configs
  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      local conf = require "nvchad.configs.telescope"

      conf.defaults.mappings.i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<Esc>"] = require("telescope.actions").close,
        ["<C-h>"] = "which_key",
      }

      return conf
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
    dependencies = {
      "nkrkv/nvim-treesitter-rescript",
    },
  },
  {
    "williamboman/mason.nvim",
    override_options = overrides.mason,
  },
  -- Install a plugin
  {
    "dmmulroy/tsc.nvim",
    ft = { "typescript", "javascript" },
    config = function()
      require("tsc").setup {
        auto_open_qflist = true,
        auto_close_qflist = false,
        enable_progress_notifications = true,
        flags = {
          noEmit = true,
        },
        hide_progress_notifications_from_history = true,
        spinner = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
      }
    end,
  },
  {
    "dmmulroy/ts-error-translator.nvim",
    ft = { "typescript", "javascript" },
    config = function()
      require("ts-error-translator").setup()
    end,
  },
  {
    "rescript-lang/vim-rescript",
    ft = { "rescript" },
  },
  {
    "simrat39/rust-tools.nvim",
    ft = { "rust" },
    opts = function()
      return require "configs.configs.rust-tools"
    end,
    dependencies = {
      "neovim/nvim-lspconfig",
      {
        "saecki/crates.nvim",
        tag = "v0.3.0",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
          require("crates").setup {
            popup = {
              border = "rounded",
            },
          }
        end,
      },
    },
    config = function(_, opts)
      require("rust-tools").setup(opts)
    end,
  },

  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup {
        auto_approve = true,
        extensions = {
          avante = {
            make_slash_commands = true, -- make /slash commands from MCP server prompts
          },
        },
      }

      local mcphub = require "mcphub"

      mcphub.add_resource("uix", {
        name = "uix_doc",
        uri = "https://raw.githubusercontent.com/pitch-io/uix/refs/heads/master/docs/repomix-output.llm.md",
        description = "Frontend Clojurescript code using UIX",
        handler = function(req, res)
          local path = req.params.path
          return res:text(vim.fn.readfile(path)):send()
        end,
      })
    end,
  },

  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    opts = {
      -- add any opts here
      provider = "copilot",
      hints = { enabled = false },
      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub and hub:get_active_servers_prompt() or ""
      end,
      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,
    },
    build = "make", -- This is optional, recommended tho. Also note that this will block the startup for a bit since we are compiling bindings in Rust.
    disabled_tools = {
      "list_files", -- Built-in file operations
      "search_files",
      "read_file",
      "create_file",
      "rename_file",
      "delete_file",
      "create_dir",
      "rename_dir",
      "delete_dir",
      "bash", -- Built-in terminal access
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },

  {
    "Olical/conjure",
    ft = { "clojure", "funnel", "rust", "sql" },
    config = function()
      vim.cmd [[
        let g:conjure#mapping#doc_word = v:false
        let g:conjure#mapping#def_word= v:false
        let g:conjure#extract#tree_sitter#enabled = v:true
        let g:conjure#extract#tree_sitter#enabled = v:true
        let g:conjure#client#clojure#nrepl#test#raw_out = v:true
        let g:conjure#client#clojure#nrepl#eval#print_buffer_size = 8192
        "let g:conjure#client#clojure#nrepl#test#runner = "kaocha"
        " let g:conjure#client#clojure#nrepl#test#call_suffix = "{:kaocha/color? true :kaocha/reporter kaocha.report/dots :config-file \"tests.edn\"}"
        ]]
    end,
  },
  {
    "CosmicNvim/cosmic-ui",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      require("cosmic-ui").setup()
    end,
  },
  {
    "clojure-vim/vim-jack-in",
    ft = { "clojure", "funnel" },
    dependencies = {
      "tpope/vim-dispatch",
      "radenling/vim-dispatch-neovim",
    },
  },
  -- {
  --   "guns/vim-sexp",
  --   enabled = false,
  --   ft = { "clojure", "funnel" },
  --   dependencies = {
  --     "tpope/vim-repeat",
  --     "tpope/vim-surround",
  --     "tpope/vim-sexp-mappings-for-regular-people",
  --   }
  -- },
  {
    "julienvincent/nvim-paredit",
    ft = { "clojure", "funnel" },
    config = function()
      require("nvim-paredit").setup {
        filetypes = { "clojure", "funnel" },
      }
    end,
  },
  {
    "tpope/vim-surround",
    -- enabled = false,
    lazy = false,
  },
  { -- autoclose and autorename tags
    "windwp/nvim-ts-autotag",
    lazy = false,
    config = function()
      require("nvim-ts-autotag").setup {
        opts = {
          -- Defaults
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = true, -- Auto close on trailing </
        },
      }
    end,
  },
  -- "francoiscabrol/ranger.vim",
  -- ["eraserhd/parinfer-rust"] = {
  --   run = "cargo build --release",
  -- },

  -- motions
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  { "NvChad/nvcommunity" },
  { import = "nvcommunity.git.diffview" },
  { import = "nvcommunity.git.neogit" },
  { import = "nvcommunity.folds.ufo" },
  { import = "nvchad.blink.lazyspec" },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = true },
      panel = { enabled = true },
    },
  },
  {
    "windwp/nvim-autopairs",
    opts = {
      fast_wrap = {},
      disable_filetype = { "TelescopePrompt", "vim" },
      enable_check_bracket_line = false,
    },
    config = function(_, opts)
      -- Add enable_check_bracket_line = false to the options
      require("nvim-autopairs").setup(opts)

      local cond = require "nvim-autopairs.conds"
      -- local cmp_autopairs = require "nvim-autopairs.completion.cmp"
      -- require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
      --require("nvchad.configs.others").autopairs()
      require("nvim-autopairs").get_rule("'")[1].not_filetypes =
        { "scheme", "lisp", "clojure", "clojurescript", "fennel" }
      require("nvim-autopairs").get_rules("'")[1]:with_pair(cond.not_after_text "[")
    end,
  },
  -- {
  --   "saghen/blink.cmp",
  --   dependencies = { "fang2hou/blink-copilot" },
  --   opts = {
  --     sources = {
  --       default = { "copilot" },
  --       providers = {
  --         copilot = {
  --           name = "copilot",
  --           module = "blink-copilot",
  --           kind = "Copilot",
  --           score_offset = 100,
  --           async = true,
  --         },
  --       },
  --     },
  --   },
  -- },
  -- {
  --   "hrsh7th/nvim-cmp",
  --   event = "InsertEnter",
  --   dependencies = {
  --     {
  --       -- snippet plugin
  --       "L3MON4D3/LuaSnip",
  --       dependencies = "rafamadriz/friendly-snippets",
  --       opts = { history = true, updateevents = "TextChanged,TextChangedI" },
  --       config = function(_, opts)
  --         require("luasnip").config.set_config(opts)
  --         require "nvchad.configs.luasnip"
  --       end,
  --     },
  --
  --     {
  --       "supermaven-inc/supermaven-nvim",
  --       -- commit = "df3ecf7",
  --       event = "BufReadPost",
  --       enabled = false,
  --       opts = {
  --         disable_keymaps = false,
  --         disable_inline_completion = false,
  --         keymaps = {
  --           accept_suggestion = "<C-;>",
  --           clear_suggestion = "<Nop>",
  --           accept_word = "<C-y>",
  --         },
  --       },
  --     },
  --
  --     -- cmp sources plugins
  --     {
  --       "saadparwaiz1/cmp_luasnip",
  --       "hrsh7th/cmp-nvim-lua",
  --       "hrsh7th/cmp-nvim-lsp",
  --       "hrsh7th/cmp-buffer",
  --       "hrsh7th/cmp-path",
  --     },
  --   },
  --   opts = function()
  --     local config = require "nvchad.configs.cmp"
  --     config.sources = {
  --       { name = "nvim_lsp" },
  --       { name = "luasnip" },
  --       { name = "buffer" },
  --       { name = "nvim_lua" },
  --       { name = "path" },
  --       { name = "supermaven" },
  --     }
  --     return config
  --   end,
  -- },
  -- database
  -- "tpope/vim-dadbod",
  -- "kristijanhusak/vim-dadbod-ui",
  -- "kristijanhusak/vim-dadbod-completion",
  -- remove plugin
  -- ["hrsh7th/cmp-path"] = false,
}

return plugins
