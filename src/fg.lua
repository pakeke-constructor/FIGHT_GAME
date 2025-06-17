


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

---@param e Entity
function fg.destroy(e)
    table.insert(rembuffer, e)
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




function fg.defineEvent()
    assert(fg.isLoadTime())
    local funcs = objects.Array()

    local function call(...)
        for _,f in ipairs(funcs) do
            f(...)
        end
    end

    local function on(func)
        assert(fg.isLoadTime())
        funcs:add(func)
    end

    return call, on
end


