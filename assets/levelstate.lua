local graphics = require("milk.graphics")
local camera = require("camera")

local insert = table.insert
local unpack = table.unpack
local sort = table.sort
local drawx = graphics.drawx

local levelstate = {}

local function gosort(go1, go2)
    if (go1 and go1.layer or 0) < (go2 and go2.layer or 0) then
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

function levelstate:enter(_)
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

local function draw_tilemap(self)
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

function levelstate:spawn(file, props)
    props =
        props or
        {
            position = {0, 0}
        }

    -- load the go file if not already loaded
    if not self.loadedgofiles[file] then
        self.loadedgofiles[file] = loadfile(file)
    end

    -- run the file and set properties on go
    local go = self.loadedgofiles[file]()
    for k, v in pairs(props) do
        go[k] = v
    end

    insert(self.tospawn, go)
    return go
end

function levelstate:destroy(go)
    if not go.markedfordestroy then
        go.markedfordestroy = true
        insert(self.todestroy, go)
    end
end

-- luacheck: push ignore
function levelstate:update(game, dt)
    -- insert all spawned gos into active gos
    if #self.tospawn > 0 then
        for i = 1, #self.tospawn do
            local idx = #self.gameobjects + 1
            local go = self.tospawn[i]
            go._idx = idx
            self.gameobjects[idx] = go
        end
        self.tospawn = {}
        if #self.gameobjects > 1 then
            sort(self.gameobjects, gosort)
        end
    end

    -- remove all gos marked for deletion
    if #self.todestroy > 0 then
        for i = 1, #self.todestroy do
            local go = self.todestroy[i]
            self.gameobjects[go._idx] = nil
        end
        self.todestroy = {}
        if #self.gameobjects > 1 then
            sort(self.gameobjects, gosort)
        end
    end

    for _, go in pairs(self.gameobjects) do
        local _ = go.update and go:update(game, self, dt)
    end
end

function levelstate:draw(game, dt)
    draw_tilemap(self)

    for _, go in pairs(self.gameobjects) do
        local _ = go.draw and go:draw(game, self, dt)
    end
end

function levelstate:exit(game)
end
-- luacheck: pop

return new
