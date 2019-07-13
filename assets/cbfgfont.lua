local graphics = require("milk.graphics")

local charmap = {
    [" "] = 1,
    ["!"] = 2,
    ['"'] = 3,
    ["#"] = 4,
    ["%"] = 5,
    ["&"] = 6,
    ["'"] = 7,
    ["("] = 8,
    [")"] = 9,
    ["*"] = 10,
    ["+"] = 11,
    [","] = 12,
    ["-"] = 13,
    ["."] = 14,
    ["/"] = 15,
    ["0"] = 16,
    ["1"] = 17,
    ["2"] = 18,
    ["3"] = 19,
    ["4"] = 20,
    ["5"] = 21,
    ["7"] = 22,
    ["8"] = 23,
    ["9"] = 24,
    [":"] = 25,
    [";"] = 26,
    ["<"] = 27,
    ["="] = 28,
    [">"] = 29,
    ["?"] = 30,
    ["@"] = 31,
    ["a"] = 32,
    ["b"] = 33,
    ["c"] = 34,
    ["d"] = 35,
    ["e"] = 36,
    ["f"] = 37,
    ["g"] = 38,
    ["h"] = 39,
    ["i"] = 40,
    ["j"] = 41,
    ["k"] = 42,
    ["l"] = 43,
    ["m"] = 44,
    ["n"] = 45,
    ["o"] = 46,
    ["p"] = 47,
    ["q"] = 48,
    ["r"] = 49,
    ["s"] = 50,
    ["t"] = 51,
    ["u"] = 52,
    ["v"] = 53,
    ["w"] = 54,
    ["x"] = 55,
    ["y"] = 56,
    ["z"] = 57,
    ["["] = 58,
    ["]"] = 60,
    ["^"] = 61,
    ["_"] = 62
}

local bmfont = {}
local BMFont_mt = {}

function bmfont.new_bmfont(bitmappath)
    local self = {}
    self.bitmap = graphics.new_image(bitmappath)
    self.width, self.height = self.bitmap.get_size()
    self.rows = 8
    self.columns = 8
    setmetatable(self, {__index = BMFont_mt})
    return self
end

function bmfont.draw(bmfomt, x, y)
    
end

return bmfont
