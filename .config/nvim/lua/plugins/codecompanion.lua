return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "MeanderingProgrammer/render-markdown.nvim",
    },
    opts = {
      display = {
        action_palette = {
          width = 95,
          height = 10,
          prompt = "Prompt ",
          provider = "default",
          opts = {
            show_default_actions = true,
            show_default_prompt_library = true,
          },
        },
        chat = {
          icons = {
            buffer_pin = " ",
            buffer_watch = "👀 ",
          },
          debug_window = {
            width = vim.o.columns - 5,
            height = vim.o.lines - 2,
          },
          window = {
            layout = "vertical",
            border = "single",
            height = 0.8,
            width = 0.45,
            relative = "editor",
            full_height = true,
            opts = {
              breakindent = true,
              cursorcolumn = false,
              cursorline = false,
              foldcolumn = "0",
              linebreak = true,
              list = false,
              numberwidth = 1,
              signcolumn = "no",
              spell = false,
              wrap = true,
            },
          },
          token_count = function(tokens, adapter)
            return " (" .. tokens .. " tokens)"
          end,
        },
      },
      prompt_library = {
        ["My New Prompt"] = {
          strategy = "chat",
          description = "Some cool custom prompt you can do",
          prompts = {
            {
              role = "system",
              content = "You are an experienced developer with Lua and Neovim",
            },
            {
              role = "user",
              content = "Can you explain why ..."
            }
          },
        }
      },
      strategies = {
        chat = {
          adapter = "copilot",
          model = "claude-3.5-sonnet",
        },
        inline = {
          adapter = "copilot",
        },
        agent = {
          adapter = "copilot",
        },
      },
    },
    config = function(_, opts)
      require("codecompanion").setup({
        display = {
          chat = {
            intro_message = "Welcome to CodeCompanion ✨! Press ? for options",
            show_header_separator = false, -- Disabled for render-markdown.nvim
            separator = "─",
            show_references = true,
            show_settings = false,
            show_token_count = true,
            start_in_insert_mode = false,
          },
        },
      })

      -- Set up render-markdown.nvim for codecompanion buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "codecompanion",
        callback = function()
          require("render-markdown").setup({
            -- Customize render-markdown settings if needed
            headings = { "▔", "─", "┄", "┈", "┊", "╌" },
            bullets = { "•", "○", "■", "‣" },
          })
        end,
      })

      -- Keymaps
      vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
      vim.keymap.set({ "n", "v" }, "<Leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
      vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
    opts = {
      -- Optional custom configuration for render-markdown.nvim
      headings = { "▔", "─", "┄", "┈", "┊", "╌" },
      bullets = { "•", "○", "■", "‣" },
    },
  },
}
