

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


function World:addSystem(systemClass)
    self.systems[systemClass] = systemClass()
end


function World:removeSystem(systemClass)
    self.systems[systemClass] = systemClass()
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



---@param self es.World
---@param ev string
---@param func function
---@param priority number?
local function on(self, ev, func, priority)
    assert(fg.isLoadTime())
    local funcs = self.events[func]
    if (not funcs) then
        error("Invalid event: " .. tostring(ev))
    end
    funcs:add(func)
end




return World

