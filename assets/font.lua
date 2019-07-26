local graphics = require("milk.graphics")

local font = {}

--[[
    http://www.codehead.co.uk/cbfg/ is a tool for generating bit map font images from ttfs.

    this char map abides by cbfgs default export options.
--]]
font.char_map = {
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
    ["\\"] = 61,
    ["]"] = 62,
    ["^"] = 63,
    ["_"] = 64
}

local function new(image, marginx, marginy, scale)
    local instance = {}
    instance.image = image
    instance.marginx = marginx
    instance.marginy = marginy
    instance.scale = scale

    local w, h = instance.image:get_size()
    instance.rows = 8 -- default for cbfg
    instance.columns = 8 -- default for cbfg
    instance.char_width = w / instance.columns
    instance.char_height = h / instance.rows
    instance.spacex = (instance.char_width + instance.marginx) * instance.scale
    instance.spacey = (instance.char_height + instance.marginy) * instance.scale
    instance.linex = 0
    instance.liney = 0
    instance.currlinex = 0
    instance.currliney = 0
    setmetatable(instance, {__index = font})
    return instance
end

function font:print(x, y, text)
    local currlinex = 0
    local len = #text
    for i = 1, len do
        local currchar = string.sub(text, i, i)
        local cols = self.columns
        local charw, charh = self.char_width, self.char_height
        local idx = font.char_map[string.lower(currchar)]
        local row = math.floor((idx - 1) / cols)
        local col = math.floor((idx - 1) % cols)
        local srcx = col * charw
        local srcy = row * charh
        graphics.drawx(
            self.image,
            x + currlinex,
            y,
            srcx,
            srcy,
            charw,
            charh,
            self.scale,
            self.scale,
            0
        )
        currlinex = currlinex + self.spacex
    end
end

return {
    new = new
}
