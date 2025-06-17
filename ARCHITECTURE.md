

## ARCHITECTURE PLANNING:


Everything in `src` is loaded once.
It represents all the engine stuff.
```
src/
    es/ entity-system stuff
    objects/ common data-structures
    fg.lua  core API, exposed to world-files

    systems/ 
        Any code that makes the game "work" is here.
        Eg. draw, input, physics, enemy-spawning, etc
    entities/
        characters/ (includes ability-definitions!)
        enemies/
        objects/
        decoration/
        common/ stuff like bullets, coins, particles, etc
        powerups/
        perks/ (perks shared between all characters)
```



-------------


ECS, except ents are added to systems manually.
EG:
```lua
local e = {x=1, y=1, image="bullet"}




local Sys = fg.System()

function Sys:init()
    self.data = 5 
    -- store any data you want here.
    -- will be saved alongside the world.

    -- when a new world is created, 
    -- the `:init` function will be called again
end


function Sys:drawEntity(ent)
    -- called when you do `world:call("drawEntity", ent)`
end


fg.getSystem(SystemClass) -- gets the system-instance from a SystemClass
fg.getWorld()








local DrawSys = fg.GroupSystem("DrawSys")

function DrawSys:onAdded(ent)
end
function DrawSys:onRemove(ent)
end

DrawSys:on(ev, func)

DrawSys:add(e)
DrawSys:remove(e)

DrawSys:flush()
-- does all addition operations, and all removal operations.
-- (called automaticaly)



```

