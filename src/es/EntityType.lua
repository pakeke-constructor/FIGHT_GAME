


local Entity = {}


function Entity:getEntityType()
    return self.___etype
end



function Entity:isSharedComponent(comp)
    local etype = self.___etype
    return (not rawget(self, comp)) and rawget(etype, comp) ~= nil
end
function Entity:isRegularComponent(comp)
    return rawget(self, comp) ~= nil
end
function Entity:hasComponent(comp)
    return rawget(self, comp) ~= nil
end


function Entity:_ensureAttachments()
    if self.attachments then
        return
    end

    self.attachments = {
        calls = {--[[
            [event] -> {atch1, atch2, ... }
        ]]}
    }
end


function Entity:attach(attachment)
    self:_ensureAttachments()
end

function Entity:detach(attachment)

end



function Entity:_call(event, ...)

end


function Entity:getWorld()
    return self._world
end

function Entity:getTypename()
    return self._name
end



---@param comp string
---@param val any
function Entity:addComponent(comp, val)
    rawset(self,comp,val)
    local world = self:getWorld()
    world:_addComponent(self,comp)
end

---@param comp string
function Entity:removeComponent(comp)
    rawset(self,comp,nil)
    local world = self:getWorld()
    world:_removeComponent(self,comp)
end




function Entity:isDeleted()
    return self.___deleted
end

function Entity:delete()
    local w = self:getWorld()
    w:_removeEntity(self)
    self.___deleted = true
end




local function shallowCopy(etype)
    assert(not getmetatable(etype), "?")
    local cpy={}
    for k,v in pairs(etype) do
        cpy[k]=v
    end
    return cpy
end


---@param name string
---@param world es.World
---@param etype table
local function newEntityType(name, world, etype)
    etype = shallowCopy(etype)

    etype._world = world
    etype._name = name

    local ent_mt = {
        __index = etype,
        __newindex = Entity.addComponent
    }

    local function newEntityInstance(x, y, ...)
        local e = setmetatable({
            x=x, y=y
        }, ent_mt)
        if e.init then
            e:init(x, y, ...)
        end
        return e
    end

    return newEntityInstance
end



return newEntityType


