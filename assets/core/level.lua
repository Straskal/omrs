local level = {}
local Level_mt = {}

function Level_mt:start()
end

function Level_mt:tick(dt)
    for i = 1, #self.game_objects_to_spawn do
        table.insert(self.game_objects, self.game_objects_to_spawn[i])
        self.game_objects_to_spawn[i]:spawned()
    end
    self.game_objects_to_spawn = {}

    for i = 1, #self.game_objects do
        self.game_objects[i]:tick(dt)
    end
end

function Level_mt:draw(dt)
    for i = 1, #self.game_objects do
        self.game_objects[i]:draw(dt)
    end
end

function Level_mt:stop()
end

function Level_mt:spawn(gameobject)
    table.insert(self.game_objects_to_spawn, gameobject)
end

function level.new()
    local self = {}
    self.game_objects = {}
    self.game_objects_to_spawn = {}
    self.game_objects_to_destroy = {}
    setmetatable(self, { __index = Level_mt })
    return self
end

return level