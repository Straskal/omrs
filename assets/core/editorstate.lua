local gamestate = require("assets.core.gamestate")
local graphics = require("milk.graphics")
local gui = require("assets.utils.gui")

local editorstate = {}
local EditorState_mt = gamestate.new()

function EditorState_mt:enter()
    self.gui_layer = gui.new_layer()
end

function EditorState_mt:draw(game, _)
    self.gui_layer:begin_frame()
    self.gui_layer:panel(0, 0, _G.RESOLUTION.w * 0.22, _G.RESOLUTION.h * 1)
    if self.gui_layer:button(1, _G.RESOLUTION.w * 0.01, _G.RESOLUTION.h * 0.01, 60, 20, "lvls") then
        print("lvls clicked")
    end
    if self.gui_layer:button(2, _G.RESOLUTION.w * 0.11, _G.RESOLUTION.h * 0.01, 60, 20, "tiles") then
        print("tiles clicked")
    end
    if self.gui_layer:button(3, _G.RESOLUTION.w * 0.01, _G.RESOLUTION.h * 0.07, 60, 20, "objs") then
        print("objs clicked")
    end
    if self.gui_layer:button(4, _G.RESOLUTION.w * 0.9, _G.RESOLUTION.h * 0.01, 60, 20, "exit") then
        game:pop_state()
    end
    self.gui_layer:end_frame()

    graphics.set_draw_color(0.8, 0, 0, 1)
    gui.style.font:printx(15, _G.RESOLUTION.h * 0.95, "OMRS [defcolor] editor")
end

function EditorState_mt:exit(_, _)
    self.gui_layer:pop()
end

function editorstate.new()
    local self = {}
    setmetatable(self, {__index = EditorState_mt})
    return self
end

return editorstate