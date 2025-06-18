

---@class es.System
---@field world es.World
local System = {}
local System_mt = {}



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


local function newSystemClass()
    local systemClass = {}
    local systemClass_mt = {
        __index = System,
        __newindex = function(t,k,v)
            if System[k] then
                error("Attempted to overwrite privaleged method")
            end
            rawset(t,k,v)
        end
    }
end

return 

