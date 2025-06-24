


-- relative-require
do
local stack = {""}
local oldRequire = require
local function stackRequire(path)
    table.insert(stack, path)
    local result = oldRequire(path)
    table.remove(stack)
    return result
end


--[[
we *MUST* overwrite `require` here,
or else the stack will become malformed.
]]
function _G.require(path)
    if (path:sub(1,1) == ".") then
        -- its a relative-require!
        local lastPath = stack[#stack]
        if lastPath:find("%.") then -- then its a valid path1
            local subpath = lastPath:gsub('%.[^%.]+$', '')
            return stackRequire(subpath .. path)
        else
            -- we are in root-folder; remove the dot and require
            return stackRequire(path:sub(2))
        end
    else
        return stackRequire(path)
    end
end

end




--[[
=========
GLOBALS START
=========
]]
_G.json = require("lib.json")
_G.consts = require("src.consts")

_G.log = require("src.log")

---@diagnostic disable-next-line
_G.typecheck = require("src.typecheck.typecheck")

_G.objects = require("src.objects.objects")

_G.fg = require("src.fg")
--[[
=========
GLOBALS END
=========
]]


setmetatable(_G, {
    __newindex = function (t,k)
        error("no new globals! " .. tostring(k))
    end,
    __index = function (t, k)
        error("dont access undefined vars! " .. tostring(k))
    end
})


if consts.TEST then
    require("src.es._ES_tests")
end

require("src.events_questions")





function love.draw()
    local w = fg.tryGetWorld()
    if w then
        w:call("draw")
    end
end


function love.update(dt)
    local w = fg.tryGetWorld()
    if w then
        w:call("update", dt)
    end
end


function love.load()
    fg.newWorld()
end


