-- Set leader key to space
vim.g.mapleader = " "

-- Open netrw file explorer with <leader>pv
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Insert mode mappings for auto-pairs and new lines
vim.api.nvim_set_keymap('i', '"', '""<left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', "'", "''<left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '(', '()<left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '[', '[]<left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '{', '{}<left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '{<CR>', '{<CR>}<ESC>O', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '(<CR>', '(<CR>)<ESC>O', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', ';<CR>', ';<CR>;<ESC>O', { noremap = true, silent = true })

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
