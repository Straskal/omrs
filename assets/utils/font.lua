local graphics = require("milk.graphics")

local font = {}
local Font_mt = {}

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

--[[
    different commands to call from text
--]]
font.commands = {
    -- items are display as yellow text
    item = function()
        graphics.set_draw_color(1, 1, 0, 1)
    end,
    -- returns the draw color back to its default
    defcolor = function()
        graphics.set_draw_color(1, 1, 1, 1)
    end,
    -- inserts and extra space
    sp = function(fnt)
        fnt.currlinex = fnt.currlinex + fnt.spacex
    end,
    -- ends the current line
    endl = function(fnt)
        fnt.currlinex = fnt.linex
        fnt.currliney = fnt.currliney + fnt.spacey
    end,
    -- concatenate two tokens together instead of putting a space inbetween
    ["+"] = function(fnt)
        fnt.currlinex = fnt.currlinex - fnt.spacex
    end
}

local function new_font(image, marginx, marginy, scale)
    local self = {}
    self.image = image
    self.marginx = marginx
    self.marginy = marginy
    self.scale = scale

    local w, h = self.image:get_size()
    self.rows = 8 -- default for cbfg
    self.columns = 8 -- default for cbfg
    self.char_width = w / self.columns
    self.char_height = h / self.rows
    self.spacex = (self.char_width + self.marginx) * self.scale
    self.spacey = (self.char_height + self.marginy) * self.scale
    self.linex = 0
    self.liney = 0
    self.currlinex = 0
    self.currliney = 0
    setmetatable(self, {__index = Font_mt})
    return self
end

function Font_mt:print_bound(x, y, w, h, text)
    self.currlinex = 0
    self.currliney = 0
    local len = #text
    local txtw, txth = len * self.spacex, self.spacey
    local drawx, drawy = x + ((w - txtw) / 2), y + ((h - txth) / 2) + 2
    for i = 1, #text do
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
            drawx + self.currlinex,
            drawy + self.currliney,
            srcx,
            srcy,
            charw,
            charh,
            self.scale,
            self.scale,
            0
        )
        self.currlinex = self.currlinex + self.spacex
    end
end

function Font_mt:printx(x, y, text, wrapat)
    self.linex = x
    self.liney = y
    self.currlinex = x
    self.currliney = y

    -- split text up by whitespace
    local tokens = {}
    for tok in text:gmatch("%S+") do
        table.insert(tokens, tok)
    end

    for i = 1, #tokens do
        local currtoken = tokens[i]
        local len = #currtoken
        -- first check to see if we need to execute a command
        if string.sub(currtoken, 1, 1) == "[" and string.sub(currtoken, len, len) == "]" then
            local cmd = string.sub(currtoken, 2, len - 1)
            font.commands[cmd](self)
            -- remove whitespace that was entered for command syntax
            self.currlinex = self.currlinex - self.spacex
        else
            local linew = (self.currlinex - self.linex) + (len * self.spacex)
            if wrapat and (linew > (wrapat * self.spacex)) then
                self.currlinex = self.linex
                self.currliney = self.currliney + self.spacey
            end
            local j = 1
            while j <= len do
                local currchar = string.sub(currtoken, j, j)
                local cols = self.columns
                local w, h = self.char_width, self.char_height
                local idx = font.char_map[string.lower(currchar)]
                local row = math.floor((idx - 1) / cols)
                local col = math.floor((idx - 1) % cols)
                local srcx = col * w
                local srcy = row * h
                graphics.drawx(self.image, self.currlinex, self.currliney, srcx, srcy, w, h, self.scale, self.scale, 0)
                self.currlinex = self.currlinex + self.spacex
                j = j + 1
            end
        end
        self.currlinex = self.currlinex + self.spacex
    end
end

return {
    new_font = new_font
}
