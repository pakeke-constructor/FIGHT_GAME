


local fg = {}



local isLoadTime = true

---@return boolean
function fg.isLoadTime()
    return isLoadTime
end

function fg.finishLoading()
    isLoadTime = false
end



local ents = {}
local rembuffer = {}

---@alias Entity table<string, any>

---@param e Entity
function fg.create(e)
    ents[e] = true
end
function fg.delete(e)
    table.insert(rembuffer, e)
end

---@param e Entity
function fg.destroy(e)
    fg.delete(e)
    fg.call("destroy", e)
end

---@param e Entity
function fg.exists(e)
    return ents[e]
end




function fg.walkDirectory(path, func)
    local info = love.filesystem.getInfo(path)
    if not info then return end

    if info.type == "file" then
        func(path)
    elseif info.type == "directory" then
        local dirItems = love.filesystem.getDirectoryItems(path)
        for _, pth in ipairs(dirItems) do
            fg.walkDirectory(path .. "/" .. pth, func)
        end
    end
end


function fg.requireFolder(path)
    fg.walkDirectory(path:gsub("%.", "/"), function(pth)
        if pth:sub(-5,-1) == ".lua" then
            pth = pth:sub(1, -5)
            log.trace("loading file:", path)
            require(pth:gsub("%/", "."))
        end
    end)
end




--- events:
--- fg.on, fg.call, fg.defineEvent
do
local events = {--[[
    [name] -> { f1, f2, ... }
]]}


function fg.defineEvent(ev)
    assert(fg.isLoadTime())
    events[ev] = objects.Array()
end

---@param ev string
---@param ... unknown
function fg.call(ev, ...)
    local funcs = events[ev]
    if (not funcs) then
        error("Invalid event: " .. tostring(ev))
    end
    for _,f in ipairs(funcs) do
        f(...)
    end
end

---@param ev string
---@param func fun(...):nil
function fg.on(ev, func)
    assert(fg.isLoadTime())
    local funcs = events[func]
    if (not funcs) then
        error("Invalid event: " .. tostring(ev))
    end
    funcs:add(func)
end

end






