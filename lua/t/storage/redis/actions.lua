local t = t or require "t"

local action=function(to)
  return function(self, ...) return self.__[to](self.__, self.___, ...) end
end

return function(list)
  local r={}
  if type(list)=='string' then list=list:split() end
  if type(list)=='table' then for it in table.iter(list) do r[it]=action(it) end end
  return r
end
