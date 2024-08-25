# t.storage.redis: redis object interface
Redis object interface linkable as cache <-> object. Interface implemented using lua operator metamethods.

Queue object interface:
```lua
local t = require "t"
local redis = t.storage.redis   -- redis object interface: queue, cache objects

local queue = redis.queue.id    -- select queue, use default connection env, use regular redis key

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
local redis = t.storage.redis
local _ = redis.cache           -- cache object, use default connection env

local cache = redis.cache.id    -- select cache
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

cache % '*'                     -- get cache keys as full names: cname:author:* (cname:author:john_doe)
cache % '**'                    -- get cache keys as short relative name: john_doe
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
- `t.storage.shm`
- `t.storage.rabbitmq`

Planned to implement:
- `t.storage.docker`
- `t.storage.mysql`
- `t.storage.pgsql`
