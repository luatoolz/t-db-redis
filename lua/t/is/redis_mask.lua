require "meta"
local mask = ("[-?+*%[%]^{}]"):matcher()
return function(x) return type(mask(x))=='string' end

--[[
h?llo matches hello, hallo and hxllo
h*llo matches hllo and heeeello
h[ae]llo matches hello and hallo, but not hillo
h[^e]llo matches hallo, hbllo, ... but not hello
h[a-b]llo matches hallo and hbllo

{a}h*llo, R

a??

[\-\?\+\*\[\]\^\{\}]
--]]
