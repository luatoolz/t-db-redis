local t = require "t"
local is = t.is
local inspect = require 'inspect'
local connection = require "t.storage.redis.connection"
local actions = assert(require "t.storage.redis.actions")
local functions = actions([[incr incrby decr decrby get set setnx del]])
local invallid = function() return nil, 'invalid object' end
local join = (':'):joiner()

local root
root=setmetatable({}, {
  __add = function(self, x)
    if x==true or x==1 then return self:incr() end
    if is.integer(x) and x~=0 then if x>0 then return self:incrby(x) else return self:decrby(-x) end end
    return tonumber(self)
  end,
  __call = function(self, to, redis)
    if type(to)~='string' or to=='' then return end
    redis=redis or connection()
    if not redis then return end
    local rv = setmetatable({__=redis, ___=to}, getmetatable(self))
    rawset(root, to, rv)
    return rv
  end,
  __div = function(self, to)
    if type(to)=='string' and to~='' then
      local name=join(self.___, to)
      return self(name, self.__)
    end
  end,
  __index = function(self, to)
    if type(to)~='string' then return end
    if not rawequal(self, root) and to=='__' then
      self[to]=connection()
      return self[to]
    end
    if to:match('^_+') then return nil end
    if functions[to] then return toboolean(self) and functions[to] or invallid end
    return self/to
  end,
  __name='t/storage/redis/counter',
  __sub = function(self, x)
    if x==true or x==1 then return self:decr() end
    if is.integer(x) and x~=0 then if x>0 then return self:decrby(x) else return self:incrby(-x) end end
    return self:get()
  end,
  __toboolean = function(self) return (self.__ and self.___) end,
  __tonumber = function(self) return tonumber(self:get()) or 0 end,
  __tostring = function(self) return self.___ or getmetatable(self).__name end,
  __unm = function(self) self:del(); return 0 end,
})
return root
