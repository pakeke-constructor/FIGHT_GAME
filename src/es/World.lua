

---@class es.World: objects.Class
local World = objects.Class("es:World")


---@alias Entity table<string,any>



function World:init()
    self.systems = {--[[
        [SystemClass] -> 
    ]]}

    self.entities = {--[[
        [e] -> true
    ]]}

    self.rembuffer = objects.Set()

    self.events = {--[[
        [ev] -> {sys1, sys2, sys3, ...}
    ]]}
end



---@param e Entity
---@return boolean
function World:exists(e)
    return self.entities[e]
end

function World:incorporateEntity(e)
    self.entities[e] = true
end

function World:removeEntity(e)
    self.rembuffer:add(e)
end


---@param self es.World
---@param sys es.System
---@param ev string
local function addCallback(self, ev, sys)
    local systems = self.events[ev]
    if (not systems) then
        error("Invalid event: " .. tostring(ev))
    end
    systems:add(sys)
end

---@param self es.World
---@param ev string
---@param sys es.System
local function removeCallback(self, ev, sys)
    local systems = self.events[ev]
    if (not systems) then
        error("Invalid event: " .. tostring(ev))
    end
    for i, syss in ipairs(funcs) do
        if syss == sys then
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
        addCallback(self, cb, sys)
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

