local window = require("milk.window")
local keyboard = require("milk.keyboard")
local graphics = require("milk.graphics")
local audio = require("milk.audio")
local keys = keyboard.keys

local game = {}

-- initialization logic goes here
function game:start()
	window.set_title("milk")
	window.set_icon("res/milkicon.png")
	window.set_size(1280, 720)
	graphics.set_virtual_resoution(640, 360)

	self.image = graphics.new_image("res/milk.png")
	local w, h = self.image:get_size()
	self.pos = { x = (640 / 2) - (w / 2), y = (360 / 2) - (h / 2) }

	self.music = audio.new_music("res/08 Ascending.mp3") -- by Eric Skiff
	self.music:loop(1)
end

-- game logic goes here
function game:tick()
	if keyboard.is_key_released(keys.ESCAPE) then 
		window.close() 
	end
end

-- draw calls go here
function game:draw()
	graphics.draw(self.image, self.pos.x, self.pos.y)
end

return game