return {
  {
    "tpope/vim-fugitive",  -- Fugitive plugin
    config = function()
      -- Example Fugitive keybindings
      -- You can customize these keybindings as per your needs
      vim.api.nvim_set_keymap("n", "<Leader>gs", ":Gstatus<CR>", { noremap = true, silent = true })  -- Git status
      vim.api.nvim_set_keymap("n", "<Leader>gc", ":Gcommit<CR>", { noremap = true, silent = true })  -- Git commit
      vim.api.nvim_set_keymap("n", "<Leader>gd", ":Gdiff<CR>", { noremap = true, silent = true })    -- Git diff
      vim.api.nvim_set_keymap("n", "<Leader>gl", ":Glog<CR>", { noremap = true, silent = true })     -- Git log
      vim.api.nvim_set_keymap("n", "<Leader>gp", ":Gpush<CR>", { noremap = true, silent = true })    -- Git push
    end
  },
}

