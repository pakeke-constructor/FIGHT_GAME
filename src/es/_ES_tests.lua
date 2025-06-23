


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


local System = require(".System")
local ComponentSystem = require(".ComponentSystem")
local World = require(".World")




---@type es.World
local w = World()
---@cast w es.World


local function clearWorld()
    w:flush()
    for e,_ in pairs(w.entities) do
        e:delete()
    end
    w:flush()
end





-- event defs
do
local function defEvent(ev)
    w:defineEvent(ev)
    fg.defineEvent(ev)
end

defEvent("testState")
defEvent("errorCall")
defEvent("assertEntityCount")
end





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
clearWorld()
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
clearWorld()
w:call("assertEntityCount", 0)
end





-- testing same-frame add/remove operations
do
w:addSystem(CS)
w:defineEntity("same_frame_1", { foo = "initial" })
w:defineEntity("same_frame_2", {})

-- Start with a clean state
w:flush()
w:call("assertEntityCount", 0)

-- Create entities in same frame
local e1 = w:newEntity("same_frame_1", 1, 1)
local e2 = w:newEntity("same_frame_2", 2, 2)
local e3 = w:newEntity("same_frame_2", 3, 3)

-- Add components to make them tracked by ComponentSystem
e2.foo = "added"
e3.foo = "added"

-- Should still be 0 before flush (operations are deferred)
w:call("assertEntityCount", 0)

-- Delete one entity in same frame as creation
e2:delete()

-- Remove component from another entity in same frame
e3:removeComponent("foo")

-- Should still be 0 before flush
w:call("assertEntityCount", 0)

-- Now flush and see final result
w:flush()

-- Should only have e1 (e2 was deleted, e3 had foo removed)
w:call("assertEntityCount", 1)

-- Test rapid add/remove/add cycle in same frame
local e4 = w:newEntity("same_frame_2", 4, 4)
e4.foo = "rapid"
e4:removeComponent("foo")
e4.foo = "re-added"

-- Should still be 1 before flush
w:call("assertEntityCount", 1)
w:flush()
-- Should be 2 after flush (e1 + e4)
w:call("assertEntityCount", 2)

-- Test delete and recreate with same definition in same frame
e4:delete()
local e5 = w:newEntity("same_frame_2", 5, 5)
e5.foo = "new"

w:call("assertEntityCount", 2) -- before flush
w:flush()
w:call("assertEntityCount", 2) -- after flush (e4 deleted, e5 added)

clearWorld()
end



print("===============")
print("ES TESTS PASSED")
print("===============")

