

---@class es.System: objects.Class
local System = objects.Class("es:System")



function System:init(world)
    assert(world,"?")
    self.world = world
end


function System:getWorld()
    return self.world
end


