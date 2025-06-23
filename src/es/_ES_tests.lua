

local System = require(".System")
local ComponentSystem = require(".ComponentSystem")
local World = require(".World")



local function assertTablesEqual(expected, actual, message)
    message = message or "Assertion failed"
    assert(type(expected) == "table")
    assert(type(actual) == "table")

    for key, expectedValue in pairs(expected) do
        if actual[key] ~= expectedValue then
            error(message .. ": key '" .. key .. "' expected " .. tostring(expectedValue) .. ", got " .. tostring(actual[key]))
        end
    end

    for key, actualValue in pairs(actual) do
        if expected[key] == nil then
            error(message .. ": unexpected key '" .. key .. "' with value " .. tostring(actualValue))
        end
    end
end



---@type es.World
local w = World()
---@cast w es.World

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
w:defineComponent("bar")
w:defineComponent("sharedComp")


-- basic entity tests
do
w:defineEntity("enty_1", {sharedComp=3, foo = "foo"})

local e = w:newEntity("enty_1",10,20)
assert(e.x == 10)
assert(e.y == 20)
e:addComponent("foo", 1)
e:addComponent("bar", 2)
assert(e.foo == 1 and e.bar == 2)
e:removeComponent("bar")
assert(not e.bar)

assert(e:isRegularComponent("x"))
assert(e:isRegularComponent("foo"))
assert(e:isSharedComponent("sharedComp"))
assert(not e:isSharedComponent("y"))
assert(not e:isRegularComponent("sharedComp"))

assert(e:hasComponent("foo") and e:hasComponent("y"))

assertTablesEqual(e:getSharedComponents(), {
    sharedComp=3, foo="foo",
    _name="enty_1", _world=w -- is hacky, BRUHHH
})
end






local CS = ComponentSystem("foo")
do
function CS:onAdded(ent)
    ent.foo = "set"
end
function CS:onRemoved(ent)
end
function CS:assertEntityCount(x)
    if (x ~= self:getEntityCount()) then
        error(("entity count expected %d, but was %d")
            :format(x, self:getEntityCount()))
    end
end
end




-- testing component-systems
do
w:addSystem(CS)
w:defineEntity("cs_1", { foo = 1 })
w:defineEntity("cs_2", {})

local e0 = w:newEntity("cs_1",0,0)
local e1 = w:newEntity("cs_2",0,0)

local e2 = w:newEntity("cs_2",0,0)
local e3 = w:newEntity("cs_2",0,0)
e2.foo = 1
e3.foo = 1

w:call("assertEntityCount", 0)
w:flush()
w:call("assertEntityCount", 3)

e2:delete()
w:call("assertEntityCount", 3)
w:flush()
w:call("assertEntityCount", 2) -- e2 was deleted
w:flush()
e3:removeComponent("foo")
w:call("assertEntityCount", 2) -- should be same...
w:flush()
w:call("assertEntityCount", 1) -- after flush, e3 was removed too

end




print("===============")
print("ES TESTS PASSED")
print("===============")

