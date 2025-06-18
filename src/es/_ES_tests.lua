

local System = require(".System")
local GroupSystem = require(".GroupSystem")
local World = require(".World")


---@type es.World
local w = World()

local A = System()
function A:init()
    self.x = 0
end

function A:testState()
    self.x = self.x + 1
end

function A:errorCall()
    error("fail")
end


w:defineEvent("testState")
w:defineEvent("errorCall")



do
-- testing calls / state, and init function
w:addSystem(A)
w:call("testState")
w:call("testState")
w:call("testState")

assert(w:getSystem(A).x == 3)
end



do
-- testing system removal
w:addSystem(A)
local ok, er = pcall(w.call, w, "errorCall")
assert(not ok)

w:removeSystem(A)
w:call("errorCall")
end



print("===============")
print("ES TESTS PASSED")
print("===============")

