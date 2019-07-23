local tiny = require("thirdparty.tiny")

local floor = math.floor

local function new()
    local animation = tiny.processingSystem()
    animation.filter = tiny.requireAll("image", "animation")
    animation.time = 0

    function animation:preWrap(dt)
        self.time = self.time + dt
    end

    -- luacheck: push ignore self
    function animation:onAdd(e, _)
        e.animation.last_anim_time = 0
        e.animation.current_anim_frame = 1
        e.animation.accumulated_time = 0
        e.animation.current_clip = e.animation.clips[e.animation.current_clip]
    end
    -- luacheck: pop

    function animation:process(e, _)
        local anim = e.animation
        if self.time - anim.last_anim_time > 0.1 then
            anim.current_anim_frame = anim.current_anim_frame + 1
            if anim.current_anim_frame > #anim.current_clip then
                anim.current_anim_frame = 1
            end
            anim.last_anim_time = self.time
            local row = floor((anim.current_clip[anim.current_anim_frame] - 1) / anim.columns)
            local column = floor((anim.current_clip[anim.current_anim_frame] - 1) % anim.columns)
            local src_x = column * anim.framewidth
            local src_y = row * anim.frameheight
            e.image.src[1], e.image.src[2] = src_x, src_y
        end
    end

    return animation
end

return new
