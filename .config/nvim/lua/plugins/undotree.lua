return {
  {
    "mbbill/undotree",  -- Undotree plugin
    config = function()
      -- Keybinding to toggle Undotree
      vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { noremap = true, silent = true })
    end
  },
}

