local tiny = require("thirdparty.tiny")

local function new()
    local update = tiny.processingSystem()
    update.filter = tiny.requireAll("update")

    -- luacheck: push ignore self
    function update:process(e, dt)
        e:update(dt)
    end
    -- luacheck: pop

    return update
end

return {
    new = new
}
