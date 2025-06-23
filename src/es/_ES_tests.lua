

local System = require(".System")
local ComponentSystem = require(".ComponentSystem")
local World = require(".World")


---@type es.World
local w = World()

local A = System()
do
function A:init()
    self.x = 0
end
function A:testState()
    self.x = self.x + 1
end
function A:errorCall()
    error("fail")
end
end



-- event defs
do
w:defineEvent("testState")
w:defineEvent("errorCall")

w:defineEvent("assertEntityCount")
end



-- testing calls / state, and init function
do
w:addSystem(A)
w:call("testState")
w:call("testState")
w:call("testState")

assert(w:getSystem(A).x == 3)
end



-- testing system removal
do
w:addSystem(A)
local ok, er = pcall(w.call, w, "errorCall")
assert(not ok)

w:removeSystem(A)
w:call("errorCall")
end






w:defineComponent("foo")
local CS = ComponentSystem("foo")
do
function CS:onAdded(ent)
    ent.foo = "set"
end
function CS:onRemoved(ent)
    print("ja!", ent)
end
function CS:assertEntityCount(x)
    assert(x == self:getEntityCount())
end
end


-- testing component-systems
do
w:addSystem(CS)
w:defineEntity("cs_1", { foo = 1 })
w:defineEntity("cs_2", {})

w:newEntity("cs_1",0,0)
w:newEntity("cs_2",0,0)
local e = w:newEntity("cs_2",0,0)
e.foo = 1

w:call("assertEntityCount", 0)
w:flush()
w:call("assertEntityCount", 2)
e:delete()
w:call("assertEntityCount", 2)
w:flush()
w:call("assertEntityCount", 1)
end




print("===============")
print("ES TESTS PASSED")
print("===============")

