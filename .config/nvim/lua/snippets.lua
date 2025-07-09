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
        self.${5:assertEqual}(${6:actual}, ${7:expected})

if __name__ == '__main__':
    unittest.main()
]],
    testfunc = [[
def test_${1:function_name}(self):
    self.${2:assertEqual}(${3:actual}, ${4:expected})
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

    vim.keymap.set("i", "<C-k>", function()
        if vim.snippet.active({ direction = 1 }) then
            vim.snippet.jump(1)
        else
            vim.cmd("normal! <C-k>")
        end
    end, { silent = true })

    vim.keymap.set("i", "<C-l>", function()
        if vim.snippet.active({ direction = -1 }) then
            vim.snippet.jump(-1)
        else
            vim.cmd("normal! <C-l>")
        end
    end, { silent = true })

    vim.keymap.set("n", "<CR>", function()
        vim.snippet.stop(1)
        return "\n"
    end, { expr = true, silent = true })

end

return M

