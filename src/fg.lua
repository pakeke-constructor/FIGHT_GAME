


---@class fg
local fg = {}



local isLoadTime = true

---@return boolean
function fg.isLoadTime()
    return isLoadTime
end

function fg.finishLoading()
    isLoadTime = false
end




local events = objects.Array()

function fg.defineEvent(ev)
    assert(fg.isLoadTime())
    events:add(ev)
end



local es = require("src.es.es")

fg.System = es.System
fg.GroupSystem = es.GroupSystem
fg.Attachment = es.Attachment



---@type es.World?
local currentWorld = nil

function fg.newWorld()
    currentWorld = es.World()
    for _,ev in ipairs(events) do
        currentWorld:defineEvent(ev)
    end

    -- add all auto-systems
end


---@return es.World
function fg.getWorld()
    return assert(currentWorld)
end


---@param e Entity
function fg.create(e)
    assert(currentWorld)
    currentWorld:incorporateEntity(e)
end

---@param e Entity
function fg.delete(e)
    if currentWorld then
        currentWorld:removeEntity(e)
    end
end


---@param e Entity
function fg.destroy(e)
    if currentWorld then
        fg.delete(e)
        currentWorld:call("destroy", e)
    end
end


---@param e Entity
function fg.exists(e)
    return currentWorld and currentWorld:exists(e)
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



