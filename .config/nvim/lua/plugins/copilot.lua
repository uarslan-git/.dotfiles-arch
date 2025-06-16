-- ~/.config/nvim/lua/plugins/copilot.lua

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- Custom options for Copilot Chat plugin
      -- Example:
      -- debug = true,
    },
    -- You can define lazy-load triggers for commands or events
    -- Example:
    -- event = "BufRead",
    -- commands = { "CopilotChat" },
  }
}

