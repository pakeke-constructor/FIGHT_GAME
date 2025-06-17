

## ARCHITECTURE PLANNING:

ECS, except ents are added to systems manually.
EG:
```lua
local e = {x=1, y=1, image="bullet"}


fg.create(e)

fg.destroy(e)
-- removes from all groups

fg.exists(e) -- true or false


fg.defineEvent(ev)
fg.call(ev, ...)
fg.on(func)

fg.callo(ev, ent, ...)
-- same as `call`, but will call methods on `ent` too.







local drawGroup = fg.Group()

drawGroup:add(e)
drawGroup:remove(e)

drawGroup:flush()
-- does all addition operations, and all removal operations.
-- (called automaticaly)

```

