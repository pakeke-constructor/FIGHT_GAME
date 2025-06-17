


---@class GroupSystem: objects.Class
local GroupSystem = objects.Class("GroupSystem")


function GroupSystem:init()
    self._addbuffer = objects.Array()
    self._entities = objects.Array()
end


function GroupSystem:addInstantly(e)
    assert(fg.exists(e))

end
function GroupSystem:addBuffered(e)
    assert(fg.exists(e))
end

GroupSystem.add = GroupSystem.addInstantly



function GroupSystem:removeInstantly(e)
    assert(fg.exists(e))
end


---@return fun(table: Entity[], i?: integer):integer, Entity[], number
function GroupSystem:ipairs()
    ---@diagnostic disable-next-line
    return ipairs(self._entities)
end


function GroupSystem:flush()
    for _, e in ipairs(self._addbuffer) do
        self:addInstantly(e)
    end
end


return GroupSystem

