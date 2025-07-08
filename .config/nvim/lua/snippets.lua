-- ~/.config/nvim/lua/snippets.lua
local M = {}

M.python = {
    testclass = [[
import unittest

class ${1:TestClass}(unittest.TestCase):
    def setUp(self):
        ${2:pass}

    def tearDown(self):
        ${3:pass}

    def test_${4:feature}(self):
        ${5:assert ...}
]],
    testfunc = [[
def test_${1:function_name}(self):
    ${2:assert ...}
]]
}

-- Function to expand a snippet
function M.expand_snippet(name)
    local ft = vim.bo.filetype
    local snippet = M[ft] and M[ft][name]
    if snippet then
        vim.snippet.expand(snippet)
    else
        vim.notify("No snippet found for: " .. name, vim.log.levels.WARN)
    end
end

-- Function to set up key mappings for snippet expansion
function M.setup_mappings()
    vim.keymap.set("i", "<leader>tc", function() M.expand_snippet("testclass") end, { desc = "Insert Python test class snippet" })
    vim.keymap.set("i", "<leader>tf", function() M.expand_snippet("testfunc") end, { desc = "Insert Python test function snippet" })

    vim.keymap.set({ 'i', 's' }, '<Tab>', function()
        if vim.snippet.active({ direction = 1 }) then
            return '<Cmd>lua vim.snippet.jump(1)<CR>'
        else
            return '<Tab>'
        end
    end, { desc = '...', expr = true, silent = true })

    vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
        if vim.snippet.active({ direction = -1 }) then
            return '<Cmd>lua vim.snippet.jump(-1)<CR>'
        else
            return '<S-Tab>'
        end
    end, { desc = 'Jump to previous snippet placeholder', expr = true, silent = true })

end

return M

