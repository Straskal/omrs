local graphics = require("milk.graphics")
local audio = require("milk.audio")

local assets = {}

local function new()
    return setmetatable(
        {
            loadedassets = {}
        },
        {__index = assets}
    )
end

function assets:load_image(path)
    if not self.loadedassets[path] then
        self.loadedassets[path] = graphics.new_image(path)
    end
end

function assets:load_sound(path)
    if not self.loadedassets[path] then
        self.loadedassets[path] = audio.new_sound(path)
    end
end

function assets:load_music(path)
    if not self.loadedassets[path] then
        self.loadedassets[path] = audio.new_music(path)
    end
end

function assets:get(path)
    if not self.loadedassets[path] then
        error("asset has not been loaded: " .. path)
    end
    local asset = self.loadedassets[path]
    local mt = getmetatable(asset)
    if mt.__name == "milk.image" then
        return asset
    end
    -- sounds and music need have instance specific data, so we have to create brand new ones.
    if mt.__name == "milk.sound" then
        return audio.new_sound(tostring(asset))
    end
    if mt.__name == "milk.music" then
        return audio.new_music(tostring(asset))
    end
end

return {
    new = new
}
