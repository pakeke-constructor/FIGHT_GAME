


local fg = {}



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


