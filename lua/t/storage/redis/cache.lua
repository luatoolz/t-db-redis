local t = require "t"
local is = t.is
local iter = table.iter
local connection = require "t.storage.redis.connection"
local json = t.format.json

local delim = ':'
local function last(to) return type(to)=='string' and to:match('[^:]+$') or nil end
local function totable(x) if is.json(x) then x=json.decode(x); return x end end

return setmetatable({}, {
  __add = function(self, x)
    if type(x)=='table' and self.__ then for k,v in pairs(x) do self.__:set(self/k, v) end end; return self end,
  __call = function(self, redis, to) if type(next(self))=='nil' and redis then
    local rv = setmetatable({__=redis, ___=to, ____=self}, getmetatable(self)); rawset(self, to, rv); return rv end end,
  __concat = function(self, to) return self+to end,
  __div = function(self, to) assert(type(to)=='string'); return to:match(':') and to or delim:zjoin(tostring(self), to) end,
  __eq = function(self, to) return is.table.indexed(to) and is.same_values(table.map(self), to) or table.equal(table.clone(self, true), to) end,
  __index = function(self, x) if type(x)=='string' and x:match('^_+') then return nil end
    if type(next(self))=='nil' then return self(connection(), self/x) end;
    if self.__ then
      local rv=self.__:get(self/x)
      return rv and (tonumber(rv) or totable(rv) or tostring(rv)) or nil
    end end,
  __iter = function(self) return iter(self % '*') end,
  __len = function(self) return tonumber(self) end,
  __mod = function(self, to) return (self and self.__ and to) and t.array(self.__:keys(self/to))*last or {} end,
  __name='t/storage/redis/cache',
  __newindex = function(self, x, v) if self.__ then if type(v)~='nil' then
    if type(v)=='table' then v=json.encode(v) end
    self.__:set(self/x, v) else _=self-x end end end,
  __pairs=function(self) local it, k = iter(self); return function()
    k=it(); if k~=nil then return k, self[k] else return nil, nil end end end,
  __sub = function(self, x) if type(x)=='string' and self.__ then self.__:del(self/x) end; return self end,
  __toboolean=function(self) return tonumber(self)>0 end,
  __tonumber = function(self) return #(self%'*') end,
  __tostring = function(self) return delim:zjoin(self.____, self.___) or '' end,
  __unm = function(self) if self.__ then for it in iter(self) do _=self-it end end; return self end,
})
