local graphics = require("milk.graphics")

local charmap = {
    [" "] = 1,
    ["!"] = 2,
    ['"'] = 3,
    ["#"] = 4,
    ["$"] = 5,
    ["%"] = 6,
    ["&"] = 7,
    ["'"] = 8,
    ["("] = 9,
    [")"] = 10,
    ["*"] = 11,
    ["+"] = 12,
    [","] = 13,
    ["-"] = 14,
    ["."] = 15,
    ["/"] = 16,
    ["0"] = 17,
    ["1"] = 18,
    ["2"] = 19,
    ["3"] = 20,
    ["4"] = 21,
    ["5"] = 22,
    ["6"] = 23,
    ["7"] = 24,
    ["8"] = 25,
    ["9"] = 26,
    [":"] = 27,
    [";"] = 28,
    ["<"] = 29,
    ["="] = 30,
    [">"] = 31,
    ["?"] = 32,
    ["@"] = 33,
    ["a"] = 34,
    ["b"] = 35,
    ["c"] = 36,
    ["d"] = 37,
    ["e"] = 38,
    ["f"] = 39,
    ["g"] = 40,
    ["h"] = 41,
    ["i"] = 42,
    ["j"] = 43,
    ["k"] = 44,
    ["l"] = 45,
    ["m"] = 46,
    ["n"] = 47,
    ["o"] = 48,
    ["p"] = 49,
    ["q"] = 50,
    ["r"] = 51,
    ["s"] = 52,
    ["t"] = 53,
    ["u"] = 54,
    ["v"] = 55,
    ["w"] = 56,
    ["x"] = 57,
    ["y"] = 58,
    ["z"] = 59,
    ["["] = 60,
    ["]"] = 62,
    ["^"] = 63,
    ["_"] = 64
}

local bmfont = {}
local BMFont_mt = {}

function bmfont.new_font(bitmappath)
    local self = {}
    self.bitmap = graphics.new_image(bitmappath)
    self.rows = 8
    self.columns = 8
    local w, h = self.bitmap:get_size()
    self.width = w / self.columns
    self.height = h / self.rows
    setmetatable(self, {__index = BMFont_mt})
    return self
end

function bmfont.print(font, x, y, text)
    bmfont.printx(font, x, y, text, 0, 1)
end

function bmfont.printx(font, x, y, text, spacing, scale)
    graphics.set_draw_color(1, 1, 1, 1)
    local w, h = font.width, font.height
    local cols = font.columns
    local currx = x
    local curry = y
    local lower = string.lower(text)
    for i = 1, #lower do
        local c = lower:sub(i, i)
        local idx = charmap[c]
        local row = math.floor((idx - 1) / cols)
        local col = math.floor((idx - 1) % cols)
        local srcx = col * w
        local srcy = row * h
        graphics.drawx(font.bitmap, currx, curry, srcx, srcy, w, h, scale, scale, 0)
        currx = (currx + (w * scale)) + (spacing * scale)
    end
end

return bmfont
