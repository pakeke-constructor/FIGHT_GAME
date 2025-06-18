

---@class es.System
---@field world es.World
local System = {}
local System_mt = {__index = System}



---@return es.World
function System:getWorld()
    return self.world
end


--- gets events for this system
---@return string[]
function System:getEventCallbacks()
    local buf = objects.Array()
    for k,v in pairs(self) do
        if type(v) == "function" and (not System[k]) then
            buf:add(k)
        end
    end
    return buf
end


local SystemClass_mt = {
    __newindex = function(t,k,v)
        if System[k] then
            error("Attempted to overwrite privaleged method")
        end
        rawset(t,k,v)
    end
}

local function newSystemClass()
    local SystemClass = {}

    ---@param world es.World
    local function newInstance(_, world)
        assert(world,"?")
        local sys = {world = world}
        for k,v in pairs(SystemClass) do
            -- copy the methods in, for efficiency.
            -- no need to worry about metatables.
            sys[k] = v
        end
        return setmetatable(sys, System_mt)
    end

    return setmetatable(SystemClass, SystemClass_mt)
end


return newSystemClass

