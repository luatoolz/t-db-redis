# t.storage.redis: redis object interface
Redis object interface linkable as cache <-> object. Interface implemented using lua operator metamethods.

Queue object interface:
```lua
local t = require "t"
local r = t.storage.redis.queue -- queue object with default connection env, use regular redis key
local queue = q.queue_id        -- select queue

_ = queue + {...}               -- add item to queue
_ = queue .. {{}, {}, ...}      -- add bulk: array, set, etc

_ = -queue                      -- clear queue

-- also respects:
__tonumber                      -- queue elements count
__toboolean                     -- is not empty
__tostring                      -- queue object name
__iter                          -- for it in table.iter(queue) do ... end
__len                           -- same as __tonumber (but of course do not work in 5.1 etc

these metamethods respected by `t` library methods:
- table.map
- table.iter
- tostring
- toboolean
- tonumber
... and others

```

Cache object interface:
```lua
local t = require "t"
local c = t.storage.redis.cache -- cache object with default connection env
local cache = c.cache_id        -- select cache
local x = c.one.two.three       -- multi level path maps as redis key based `one:two:three`, ex. `one:two:three:1`
local o = cache.item            -- maps as redis key `cname:item`

cache.item='value'              -- string var
cache.item=4                    -- integer var
cache.item={_id=id, name='any'} -- auto converting to/from json. `_id` could be possibly compatible with mongo.ObjectID
cache.item=nil                  -- delete item

cache - 'item'                  -- deletes item from cache
cache - {'item1', 'item2', ...} -- bulk delete

-cache                          -- remove all items

_= cache + {id={a='a',x='y'}, id2={b='x'}, id3=3, id4='wow'} + {...} -- save objects with `__add` metamethod
_= cache .. {...}               -- save with `__concat` metamethod

cache % '*'                     -- get cache keys, relative match as cname:item:*
cache['*']                      -- get pairs
cache['*']=nil                  -- delete matched

-- also respects:
__tonumber                      -- elements count
__toboolean                     -- is not empty
__tostring                      -- cache object name
__iter                          -- for it in table.iter(queue) do ... end
__pairs                         -- for k,v in pairs(cache) do ... end
__len                           -- same as `__tonumber`, but of course do not work in 5.1
```

## t.storage.redis.connection
- redis connection constructor
  - fields mapped with env vars, list above
- otherwise default connection is tried: `redis://redis:6379`

## ENV
- `REDIS_HOST`
- `REDIS_PORT`
- `REDIS_DB`
- `REDIS_USER`
- `REDIS_PASS`

## depends luarocks
- `t`
- `t-env`
- `t-format-json`
- `redis-lua`
- `lua-resty-redis`

## test depends
- `busted`
- `luacheck`

## see also
- `t.storage.mongo`
- `t.storage.file`
- `t.storage.ngxshm`
- `t.storage.rabbitmq`

Planned to implement:
- `t.storage.docker`
- `t.storage.mysql`
- `t.storage.pgsql`
