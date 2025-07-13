-- Set leader key to space
vim.g.mapleader = " "

-- Open netrw file explorer with <leader>pv
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Auto-pair insert
local autopairs = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ['"'] = '"',
  ["'"] = "'",
  ["`"] = "`"
}

-- Insert pair and move cursor inside
for open, close in pairs(autopairs) do
  vim.keymap.set("i", open, function()
    local col = vim.fn.col('.')
    local line = vim.fn.getline('.')
    local next_char = line:sub(col, col)

    if next_char == close or next_char:match("[%w]") then
      return open
    end

    return open .. close .. "<Left>"
  end, { expr = true, noremap = true })
end

-- Skip over closing if already present
for _, close in pairs(autopairs) do
  vim.keymap.set("i", close, function()
    local col = vim.fn.col('.')
    local line = vim.fn.getline('.')
    if line:sub(col, col) == close then
      return "<Right>"
    else
      return close
    end
  end, { expr = true, noremap = true })
end

-- Smart enter: when pressing Enter between { }, ( ), or [ ]
vim.api.nvim_set_keymap('i', '{<CR>', '{<CR>}<ESC>O', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '(<CR>', '(<CR>)<ESC>O', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '[<CR>', '[<CR>]<ESC>O', { noremap = true, silent = true })

-- Move visual selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Join lines without moving cursor
vim.keymap.set("n", "J", "mzJ`z")

-- Scroll and center cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Search navigation centering
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Restart LSP
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

-- Paste over selection without yanking
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Ctrl-c to escape insert mode
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Disable Q key in normal mode
vim.keymap.set("n", "Q", "<nop>")

-- Open tmux sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Format buffer
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

-- Location list navigation
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Substitute word under cursor with confirmation
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Copy current file path to clipboard using xclip
vim.keymap.set("n", "<leader>xc", "<cmd>!xclip %<CR>", { silent = true })

-- Run current Python file
vim.keymap.set("n", "<leader>rp", "<cmd>term python %<CR>")

-- Run Python unittest discovery
vim.keymap.set("n", "<leader>rtp", "<cmd>!python -m unittest discover -p '*.py'<CR>")

-- Reload config
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('v', '<leader>{', 'c{<C-r>"}', opts)
vim.api.nvim_set_keymap('v', '<leader>(', 'c(<C-r>")', opts)
vim.api.nvim_set_keymap('v', '<leader>[', 'c[<C-r>"]', opts)
vim.api.nvim_set_keymap('v', '<leader>"', 'c"<C-r>""<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', [[<leader>']], [[c'<C-r>"'<Esc>]], { noremap = true, silent = true })

vim.keymap.set("n", "<leader>dp", "da(", {
  noremap = true,
  silent = true,
  desc = "Delete surrounding parentheses ()"
})

vim.keymap.set("n", "<leader>db", "da[", {
  noremap = true,
  silent = true,
  desc = "Delete surrounding square brackets []"
})

vim.keymap.set("n", "<leader>dc", "da{", {
  noremap = true,
  silent = true,
  desc = "Delete surrounding curly braces {}"
})

vim.keymap.set("n", "<leader>dq", "da\"", {
  noremap = true,
  silent = true,
  desc = "Delete surrounding double quotes \""
})

vim.keymap.set("n", "<leader>dsq", "da'", {
  noremap = true,
  silent = true,
  desc = "Delete surrounding single quotes ''"
})

vim.keymap.set("x", "<leader>d", "S", {
  expr = true,
  noremap = true,
  silent = true,
  desc = "Delete surrounding (Visual Mode)"
})

vim.keymap.set("n", "<leader>p(", "di(va(p", {
  noremap = true,
  silent = true,
  desc = "Perform di(va(p on parentheses"
})

vim.keymap.set("n", "<leader>p{", "di{va{p", {
  noremap = true,
  silent = true,
  desc = "Perform di{va{p on curly braces"
})

vim.keymap.set("n", "<leader>p[", "di[va[p", {
  noremap = true,
  silent = true,
  desc = "Perform di[va[p on square brackets"
})

vim.keymap.set("n", "<leader>p\"", "di\"va\"p", {
  noremap = true,
  silent = true,
  desc = "Perform di\"va\"p on double quotes"
})

vim.keymap.set("n", "<leader>p'", "di'va'p", {
  noremap = true,
  silent = true,
  desc = "Perform di'va'p on single quotes"
})
