-- ~/.config/nvim/luasnippets/python.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("testclass", {
        t("import unittest"),
        t(""),
        t("class "),
        i(1, "TestClass"),
        t("(unittest.TestCase):"),
        t("\tdef setUp(self):"),
        t("\t\t"),
        i(2, "pass"),
        t(""),
        t("\tdef tearDown(self):"),
        t("\t\t"),
        i(3, "pass"),
        t(""),
        t("\tdef test_"),
        i(4, "feature"),
        t("(self):"),
        t("\t\t"),
        i(5, "assert ..."),
    }),
    s("testfunc", {
        t("def test_"),
        i(1, "function_name"),
        t("(self):"),
        t("\t"),
        i(2, "assert ..."),
    }),
}
