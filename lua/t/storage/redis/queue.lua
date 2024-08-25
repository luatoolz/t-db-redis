local t = require "t"
local is = t.is
local connection = require "t.storage.redis.connection"
local actions = assert(require "t.storage.redis.actions")
local functions = actions([[rpush lpop llen del]])
local invallid = function() return nil, 'invalid object' end
local join = (':'):joiner()
local json = t.format.json
local iter=table.iter
local rpc="^%_*(.*)$"

local root={}
return setmetatable(root, {
  __add = function(self, x)
    if x and type(x)~='string' then x=json(x) end
    if x then self:__rpush(x) end
    return self
  end,
  __call = function(self, to, redis)
    if type(to)~='string' or to=='' then return end
    redis=redis or connection()
    if not redis then return end
    local rv = setmetatable({__=redis, ___=to}, getmetatable(self))
    rawset(root, to, rv)
    return rv
  end,
  __concat = function(self, x) if is.bulk(x) then for it in iter(x) do _=self+it end; return self end end,
  __div = function(self, to)
    if type(to)=='string' and to~='' then
      local name=join(self.___, to)
      return self(name, rawget(self, '__'))
    end
  end,
  __eq = function(self, to) return is.eq(table.tohash(table.map(self)), table.tohash(table.map(to))) end,
  __index = function(self, to)
    if type(to)~='string' then return end
    if not rawequal(self, root) and to=='__' then
      self[to]=connection()
      return self[to]
    end
    if to:match('^_+$') then return nil end
    if functions[to:match(rpc)] then return toboolean(self) and functions[to:match(rpc)] or invallid end
    return self/to
  end,
  __iter = function(self) return function() return self:__lpop() or nil end end,
  __len = function(self) return tonumber(self) end,
  __name='t/storage/redis/queue',
  __toboolean = function(self) return (self.__ and self.___) end,
  __tonumber = function(self) return self:__llen() or 0 end,
  __tostring = function(self) return self.___ or getmetatable(self).__name end,
  __unm = function(self) if not toboolean(self) then return false end
    self:__del()
    rawset(root, self.___, nil)
    return 0
  end,
})
