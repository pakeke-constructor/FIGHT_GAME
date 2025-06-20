


local Entity = {}


function Entity:getEntityType()
    return self.___etype
end


function Entity:getTypename()
    return self.___etype._name
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



function Entity:addComponent(comp, val)
    rawset(self,comp,val)
end
function Entity:removeComponent(comp, val)
    rawset(self,comp,nil)
end




function Entity:isDeleted()
    return self.___deleted
end

function Entity:delete()
    local etype = self:getEntityType()
    etype._world:_removeEntity(self)
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


