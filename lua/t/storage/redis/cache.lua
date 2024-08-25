local t = t or require "t"
local is = t.is
local json = t.format.json
local connection = require "t.storage.redis.connection"
local actions = assert(require "t.storage.redis.actions")

local unpack = unpack or table.unpack
local iter = table.iter
local join = (':'):joiner()
local delim = (':'):matcher()
local rpc  = ("^%_*(.*)$"):matcher()
local last = ('[^:]+$'):matcher()

local invallid = function() return nil, 'invalid object' end
local action=function(to)
  return function(self, x, v, ...)
    return self.__[rpc(to)](self.__, self/x, v, ...)
  end
end
local functions = actions([[get set keys del scan]], action)
functions.scan=function(self, ...) return self.__:scan(...) end
functions.mget=function(self, keys) return self.__:mget(unpack(self/keys)) end
functions.mdel=function(self, keys) return self.__:del(unpack(self/keys)) end

local tovalue=function(rv)
  if is.json(rv) then return json.decode(rv) end
  if rv=='true' or rv=='false' then return rv=='true' and true or false end
  return tonumber(rv) or rv
end

local root={}
return setmetatable(root, {
  __add = function(self, x) if not toboolean(self) then return end
    if type(x)=='nil' or type(x)=='boolean' or type(x)=='number' then return self end
    if is.json_array(x) then x=json.decode(x) end
    if is.bulk(x) then return self .. x end
-- TODO: t.def?
-- TODO: tojson?
    if type(x)=='table' and not getmetatable(x) then
      for k,v in pairs(x) do if type(k)~='number' then self[k]=v end end end
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
  __concat = function(self, x)
    if is.json_array(x) then x=json.decode(x) end
    if is.bulk(x) then for it in table.iter(x) do _=x+it end end
    if type(x)=='table' and not getmetatable(x) then return self + x end
    return self
  end,
  __div = function(self, to)
    if type(to)=='string' then return delim(to) and to or join(rawget(self,'___'), to) end
    if type(to)=='table' and is.bulk(to) then
      local rv={}
      for it in iter(to) do table.insert(rv, self/it) end
      return rv
    end
  end,
  __eq = function(self, to) return is.table.indexed(to) and is.values(table.map(self), to) or table.equal(table.clone(self, true), to) end,
  __index = function(self, to)
    if to=='__' then self[to]=connection(); return self[to]; end
    if type(to)=='string' and to:match('^_+$') then return nil end
    if rawequal(self, root) then return type(to)=='string' and rawget(root,self/to) or self(self/to, rawget(self, '__')) end
    if to==true or to=='' or is.table.empty(to) then return self['*'] end
    if type(to)~='string' then return end
    if functions[rpc(to)] then return toboolean(self) and functions[rpc(to)] or invallid end
    if is.redis_mask(to) then
      local trim=to=='**'
      if to=='**' then to='*' end
      local keys = self % to
      local values = assert(self:__mget(keys))
      assert(#keys == #values)
      local r={}
      for i,it in ipairs(keys) do
        r[trim and last(it) or it]=tovalue(values[i])
      end
      return r
    end
    return tovalue(self:__get(to))
  end,
  __iter = function(self) return iter(self % true) end,
  __len = function(self) return tonumber(self) end,
  __mod = function(self, to)
    if type(to)=='nil' or not toboolean(self) then return {} end
    if to==true or to=='' or is.table.empty(to) then to='*' end
    if type(to)~='string' then return {} end
    local rv=t.array()
    local limit, initial, cursor = 512, "0"
    local trim = to=='**'
    if to=='**' then to='*' end
    repeat
      local r = assert(self.__:scan(cursor or initial, {match=self/to}, {limit=limit}))
      cursor = r[1]
      _ = rv .. r[2]
    until cursor==initial
    if trim then return rv * last end
    return rv
  end,
  __name='t/storage/redis/cache',
  __newindex = function(self, to, v) if not toboolean(self) then return end
    if to==true or to=='' or to=='*' or is.table.empty(to) then to='*' end
    if is.redis_mask(to) and type(v)=='nil' then
      return assert(self:__mdel(self % to))
    end
    if type(v)=='nil' then return self:__del(to) end
    if type(v)=='number' or type(v)=='boolean' then v=tostring(v) end
    if type(v)=='table' then v=json(v) end
    self:__set(to, v)
  end,
  __pairs=function(self) local it, k = iter(self)
    return function() k=it(); if k~=nil then return k, self[k] else return nil, nil end end end,
  __sub = function(self, it) if toboolean(self) then self[it]=nil end; return self end,
  __toboolean = function(self) return (self.___ and self.__) end,
  __tostring = function(self) return self.___ or getmetatable(self).__name end,
  __tonumber = function(self) local rv=self%'*'; return tonumber(rv) or #rv or 0 end,
  __unm = function(self) if toboolean(self) then self['*']=nil; return self end end,
})
