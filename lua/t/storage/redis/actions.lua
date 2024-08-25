local t = t or require "t"

local _action=function(to)
  return function(self, ...) return self.__[to:match("^%_*(.*)$")](self.__, self.___, ...) end
end

return function(list, action)
  local r={}
  action=action or _action
  if type(list)=='string' then list=list:split() end
  if type(list)=='table' then for it in table.iter(list) do r[it]=action(it) end end
  return r
end
