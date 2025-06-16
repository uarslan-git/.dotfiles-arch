return {
  {
    "nvim-telescope/telescope.nvim",  -- Telescope plugin
    dependencies = { "nvim-lua/plenary.nvim" },  -- Telescope requires plenary.nvim as a dependency
    config = function()
      local builtin = require('telescope.builtin')

      -- Key mappings for various Telescope functions
      vim.keymap.set('n', '<leader>pf', builtin.find_files, { noremap = true, silent = true })  -- Find files
      vim.keymap.set('n', '<C-p>', builtin.git_files, { noremap = true, silent = true })        -- Git files
      vim.keymap.set('n', '<leader>ps', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })  -- Grep string with input
      end, { noremap = true, silent = true })
    end
  },
}

