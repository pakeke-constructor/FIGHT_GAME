


---@class es.ComponentSystem
local ComponentSystem = {}

local ComponentSystem_mt = {__index = ComponentSystem}



function ComponentSystem:init()
    self._addbuffer = objects.Set()
    self._rembuffer = objects.Set()
    self._entities = objects.Set()
end


local OVERRIDES = {
    init = true,
    onAdded = true,
    onRemoved = true,
}


---@param ent Entity
function ComponentSystem:onAdded(ent)
end

---@param ent Entity
function ComponentSystem:onRemoved(ent)
end


---@param e Entity
function ComponentSystem:_addInstantly(e)
    self._entities:add(e)
    self._addbuffer:remove(e)
    if self.onAdded then
        self:onAdded(e)
    end
end

---@param e Entity
function ComponentSystem:_addBuffered(e)
    self._addbuffer:add(e)
end



function ComponentSystem:_removeBuffered(e)
    self._addbuffer:remove(e)
    self._rembuffer:add(e)
end


function ComponentSystem:_removeInstantly(e)
    self._addbuffer:remove(e)
    self._entities:remove(e)
    if self.onRemoved then
        self:onRemoved(e)
    end
end


---@return fun(table: Entity[], i?: integer):integer, Entity[], number
function ComponentSystem:ipairs()
    ---@diagnostic disable-next-line
    return ipairs(self._entities)
end


function ComponentSystem:getEntityCount()
    return #self._entities
end


function ComponentSystem:_flush()
    if self._addbuffer:size() > 0 then
        -- do a copy coz we modify addbuffer when iterating
        local cpy = objects.Array(self._addbuffer)
        for _, e in ipairs(cpy) do
            self:_addInstantly(e)
        end
        self._addbuffer:clear()
    end

    if self._rembuffer:size() > 0 then
        local cpy = objects.Array(self._rembuffer)
        for _, e in ipairs(cpy) do
            self:_removeInstantly(e)
        end
        self._rembuffer:clear()
    end
end



--- gets events for this system
---@return string[]
function ComponentSystem:getEventCallbacks()
    local buf = objects.Array()
    for k,v in pairs(self) do
        if type(v) == "function" and (not ComponentSystem[k]) then
            buf:add(k)
        end
    end
    return buf
end


local function newComponentSystemClass(component)
    local SystemClass = {}
    ---@param world es.World
    local function newInstance(_, world)
        assert(world,"?")
        local sys = {
            _world = world,
            _component = component
        }
        for k,v in pairs(SystemClass) do
            -- copy the methods in, for efficiency.
            -- no need to worry about metatables.
            sys[k] = v
        end
        setmetatable(sys, ComponentSystem_mt)
        if sys.init then
            sys:init()
        end
        return sys
    end

    local SystemClass_mt = {
        __newindex = function(t,k,v)
            if ComponentSystem[k] and (not OVERRIDES[k]) then
                error("Attempted to overwrite privaleged method")
            end
            rawset(t,k,v)
        end,
        __call = newInstance
    }

    return setmetatable(SystemClass, SystemClass_mt)
end


return newComponentSystemClass


