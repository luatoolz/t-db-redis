local t = require "t"
local is = t.is
local iter = table.iter

--local meta = require "meta"
--local require = meta.require(...)
--local connection = require ".connection"
local connection = require "t.storage.redis.connection"
local functions = {rpush=true, lpop=true, llen=true}

return setmetatable({}, {
  __add = function(self, x) self:rpush(tostring(self), x); return self end,
  __call = function(self, redis, to)
    if type(next(self))=='nil' and redis then
      local rv = setmetatable({__=redis, ___=to}, getmetatable(self))
      rawset(self, to, rv)
      return rv
    end
  end,
  __concat = function(self, x) if is.bulk(x) then for it in iter(x) do _=self+it end; return self end end,
  __div = function(self, to) return type(to)~='nil' and self(self.__ or connection(), tostring(to)) or nil end,
  __index = function(self, to)
    if type(to)=='string' then
      if functions[to] then return self.__ and function(this, ...) return self.__[to](self.__, ...) end or function(this, ...) return nil end end
      if to:match('^_+') then return nil end
    end
    return self/to
  end,
  __iter = function(self) return function() return self:lpop(tostring(self)) or nil end end,
  __len = function(self) return tonumber(self) end,
  __name='t/storage/redis/queue',
  __toboolean = function(self) return tonumber(self)>0 end,
  __tonumber = function(self) return self:llen(tostring(self)) or 0 end,
  __tostring = function(self) return self.___ or '' end,
  __unm = function(self)
    rawset(self, tostring(self), nil)
    _ = table.map(self)
    return tonumber(self)
  end,
})
