local t = t or require "t"

local action=function(to)
  return function(self, ...) return self.__[to](self.__, self.___, ...) end
end
--local functions={}
--for it in table.iter(([[incr incrby decr decrby get set setnx]]):split()) do functions[it]=action(it) end

return function(list)
  if type(list)=='string' then list=list:split() end
--  assert(type(list)=='table')
  local r={}
  for it in table.iter(list) do r[it]=action(it) end
  return r
end
