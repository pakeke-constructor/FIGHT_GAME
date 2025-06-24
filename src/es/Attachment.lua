

--[[

Attachments can be explicitly "attached" to entities.

They are like systems, but only on the entity they are attached to.

]]

local Attachment = {}


function Attachment:init(n)
end


function Attachment:getEntity()
end


function Attachment:detach()
end


local A = {}
function A:init()
    self.dash = 0
end

function A:updateEntity(e, dt)
    self.dash = self.dash + dt
    if self.dash > 2 then
        self:detach()
    end
end




local function newAttachment()

end

