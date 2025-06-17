


---@class Group: objects.Class
local Group = objects.Class("Group")


function Group:init()
    self.addbuffer = objects.Array()
    self.
end


function Group:addInstantly(e)
    assert(fg.exists(e))
end
function Group:addBuffered(e)
    assert(fg.exists(e))
end

Group.add = Group.addInstantly



function Group:removeInstantly(e)
    assert(fg.exists(e))
end


function Group:flush()
    for 
end


return Group

