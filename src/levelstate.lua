local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local bump = require("libs.bump")
local debugstate = require("debugstate")
local camera = require("camera")
local assets = require("assets")

local keys = keyboard.keys
local insert = table.insert
local remove = table.remove
local unpack = table.unpack
local sort = table.sort
local drawx = graphics.drawx

local levelstate = {}

local function gosort(go1, go2)
    if (go1.layer or 0) < ((go2 and go2.layer) or 0) then
        local temp = go1._idx
        go1._idx = go2._idx
        go2._idx = temp
        return true
    end
end

local function new(levelfile)
    return setmetatable(
        {
            camera = camera(),
            assets = assets.new(),
            bumpworld = bump.newWorld(32),
            file = levelfile,
            data = {},
            tilesets = {},
            tilesheets = {},
            loadedgofiles = {},
            goindeces = {},
            gameobjects = {},
            tospawn = {},
            todestroy = {},
            leveltoload = nil
        },
        {__index = levelstate}
    )
end

local function drawtilemap(self)
    local cam = self.camera
    local tilemap = self.data.tilemap
    local tilesets = self.tilesets
    local tilesheets = self.tilesheets
    local x, y = cam:transform_point(0, 0)
    local advancex, advancey = x, y
    local mapwidth = tilemap.width
    local mapheight = tilemap.height
    local cellsz = tilemap.cellsize
    local scaledcellsz = cellsz * cam.zoom
    local numlayers = #tilemap.layers

    for i = 1, numlayers do
        local tiles = tilemap.layers[i].tiles
        local defs = tilesets[i].tiledefs
        local sheet = tilesheets[i]

        graphics.set_draw_color(unpack(tilemap.layers[i].color))

        for j = 1, mapheight do
            for k = 1, mapwidth do
                local tiledef = tiles[j][k]
                -- if there is no tile here, skip drawing
                if tiledef > 0 then
                    local tilesrc = defs[tiledef].src
                    drawx(sheet, advancex, advancey, tilesrc[1], tilesrc[2], cellsz, cellsz, cam.zoom, cam.zoom, 0)
                end
                advancex = advancex + scaledcellsz
            end
            advancex = x
            advancey = advancey + scaledcellsz
        end
        advancex, advancey = x, y
    end
end

function levelstate:preloadgo(file)
    -- load the go file and preload all assets if not already loaded
    if not self.loadedgofiles[file] then
        self.loadedgofiles[file] = dofile(file)
        self.loadedgofiles[file].preload(self)
    end
end

function levelstate:spawn(file, props)
    props = props or {position = {0, 0}}

    -- call preload on object, which can recursively call level:preload.
    -- we do this so we can load all objects in/to be spawned into a scene when the scene initially loads.
    self:preloadgo(file)

    -- create go and set properties
    local go = self.loadedgofiles[file].new(self)
    for k, v in pairs(props) do
        go[k] = v
    end

    go.level = self
    -- load the instance. all assets that this go relies on should have bee
    go:load(self)
    insert(self.tospawn, go)
    return go
end

function levelstate:destroy(go)
    if not go.markedfordestroy then
        go.markedfordestroy = true
        insert(self.todestroy, go)
    end
end

function levelstate:enter()
    -- load and run the level file
    self.data = dofile(self.file)
    local layers = self.data.tilemap.layers

    -- load the level's resources
    for i = 1, #layers do
        local tileset = dofile(layers[i].tilesetfile)
        self.tilesets[i] = tileset
        self.tilesheets[i] = graphics.new_image(tileset.imagefile)
    end

    -- spawn objects
    for i = 1, #self.data.gameobjects do
        local file = self.data.gameobjects[i].file
        self:spawn(file, self.data.gameobjects[i])
    end
end

function levelstate:refreshgolists()
    if #self.tospawn > 0 or #self.todestroy > 0 then
        for i = 1, #self.tospawn do
            local go = self.tospawn[i]
            insert(self.gameobjects, go)
        end

        self.tospawn = {}

        for i = 1, #self.todestroy do
            local go = self.todestroy[i]
            for j = 1, #self.gameobjects do
                if self.gameobjects[j] == go then
                    remove(self.gameobjects, j)
                end
            end
        end

        self.todestroy = {}

        sort(self.gameobjects, gosort)
    end
end

function levelstate:update(dt)
    -- debug tools
    if keyboard.is_key_released(keys.TILDE) then
        if self.debugtools then
            self.game:pop()
            self.debugtools = nil
        else
            self.debugtools = debugstate.new(self)
            self.game:push(self.debugtools)
        end
    end

    -- invoke all spawned callbacks
    for i = 1, #self.tospawn do
        if self.tospawn[i].spawned then
            self.tospawn[i]:spawned()
        end
    end

    -- invoke go destroyed callback
    for i = 1, #self.todestroy do
        local _ = self.todestroy[i].destroyed and self.todestroy[i]:destroyed(self)
    end

    -- insert and remove spawned and destroyed gos
    self:refreshgolists()

    for i = 1, #self.gameobjects do
        if self.gameobjects[i].update then
            self.gameobjects[i]:update(dt)
        end
    end
end

function levelstate:draw()
    drawtilemap(self)

    for i = 1, #self.gameobjects do
        if self.gameobjects[i].draw then
            self.gameobjects[i]:draw()
        end
    end
end

-- luacheck: push ignore
function levelstate:exit()
end
-- luacheck: pop

return {
    new = new
}
