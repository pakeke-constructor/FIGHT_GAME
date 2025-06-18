

---@class es.World: objects.Class
local World = objects.Class("es:World")



function World:init()
    self.systems = {--[[
        [SystemClass] -> 
    ]]}

    self.entities = objects.Set()

    self.rembuffer = objects.Set()

    self.events = {--[[
        [ev] -> {f1, f2, f3}
    ]]}
end




---@param self es.World
---@param ev string
---@param func function
local function addCallback(self, ev, func)
    local funcs = self.events[ev]
    if (not funcs) then
        error("Invalid event: " .. tostring(ev))
    end
    funcs:add(func)
end

---@param self es.World
---@param ev string
---@param func function
local function removeCallback(self, ev, func)
    local funcs = self.events[ev]
    if (not funcs) then
        error("Invalid event: " .. tostring(ev))
    end
    for i, f in ipairs(funcs) do
        if f == func then
            funcs:remove(i)
        end
    end
end




---@param systemClass System
---@return boolean
function World:addSystem(systemClass)
    if self.systems[systemClass] then return false end
    local sys = systemClass()
    for _, cb in ipairs(sys:getEventCallbacks()) do
        addCallback(self, cb, sys[cb])
    end
    self.systems[systemClass] = sys
    return true
end


---@param systemClass System
function World:removeSystem(systemClass)
    local sys = self.systems[systemClass]
    if not sys then return end
    self.systems[systemClass] = nil
    for _, cb in ipairs(sys:getEventCallbacks()) do
        removeCallback(self, cb, sys[cb])
    end
end



function World:defineEvent(ev)
    self.events[ev] = objects.Array()
end


---@param ev string
---@param ... unknown
function World:call(ev, ...)
    local funcs = self.events[ev]
    if (not funcs) then
        error("Invalid event: " .. tostring(ev))
    end
    for _,f in ipairs(funcs) do
        f(...)
    end
end




return World

