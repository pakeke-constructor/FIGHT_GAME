


---@class ComponentSystem: objects.Class
local ComponentSystem = objects.Class("ComponentSystem")


function ComponentSystem:init()
    self._addbuffer = objects.Array()
    self._entities = objects.Array()
end


---@param ent Entity
function ComponentSystem:onAdded(ent)
end

---@param ent Entity
function ComponentSystem:onRemoved(ent)
end


function ComponentSystem:addInstantly(e)
    assert(fg.exists(e))
    self._entities:add(e)
    self._addbuffer:remove(e)
    if self.onAdded then
        self:onAdded(e)
    end
end

function ComponentSystem:addBuffered(e)
    assert(fg.exists(e))
    self._addbuffer:add(e)
end

ComponentSystem.add = ComponentSystem.addInstantly



function ComponentSystem:removeInstantly(e)
    assert(fg.exists(e))
    self._addbuffer:remove(e)
    self._entities:remove(e)
    if self.onRemoved then
        self:onAdded(e)
    end
end


---@return fun(table: Entity[], i?: integer):integer, Entity[], number
function ComponentSystem:ipairs()
    ---@diagnostic disable-next-line
    return ipairs(self._entities)
end


function ComponentSystem:flush()
    if #self._addbuffer <= 0 then
        return
    end
    -- do a copy coz we modify addbuffer when iterating
    local cpy = objects.Array(self._addbuffer)
    for _, e in ipairs(cpy) do
        self:addInstantly(e)
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


return ComponentSystem

