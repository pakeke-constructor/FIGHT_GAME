

---@class es.World
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
    for i, syss in ipairs(systems) do
        if syss == sys then
            systems:remove(i)
        end
    end
end




---@param systemClass es.System
---@return boolean
function World:addSystem(systemClass)
    if self.systems[systemClass] then return false end
    local sys = systemClass(self)
    for _, cb in ipairs(sys:getEventCallbacks()) do
        addCallback(self, cb, sys)
    end
    self.systems[systemClass] = sys
    return true
end




---@param systemClass es.System
---@return es.System|table<string,any>
function World:getSystem(systemClass)
    return self.systems[systemClass]
end







---@param systemClass es.System
function World:removeSystem(systemClass)
    local sys = self.systems[systemClass]
    if not sys then return end
    self.systems[systemClass] = nil
    for _, cb in ipairs(sys:getEventCallbacks()) do
        removeCallback(self, cb, sys)
    end
end



function World:defineEvent(ev)
    self.events[ev] = objects.Array()
end


---@param ev string
---@param ... unknown
function World:call(ev, ...)
    local systems = self.events[ev]
    if (not systems) then
        error("Invalid event: " .. tostring(ev))
    end
    for _,sys in ipairs(systems) do
        sys[ev](sys, ...)
    end
end



return World

