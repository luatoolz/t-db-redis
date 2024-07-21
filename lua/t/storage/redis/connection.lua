local t = require "t"
local env = t.env
local meta = require "meta"
local red = meta.no.require("resty.redis") or meta.no.require "redis"

assert(red, 'redis module failed to load', type(meta.no.require("resty.redis")), type(meta.no.require "redis"))
print(' redis module', type(meta.no.require("resty.redis")), type(meta.no.require "redis"))

env.REDIS_HOST    = 'redis'
env.REDIS_PORT    = 6379
--env.REDIS_DB
--env.REDIS_USER
--env.REDIS_PASS

local function default()
  return {
    host = env.REDIS_HOST,
    port = env.REDIS_PORT,
    db   = env.REDIS_DB,
    user = env.REDIS_USER,
    pass = env.REDIS_PASS,
  }
end

return function(conn)
  conn=conn or default()
print(' redis()', conn.host, conn.port)
  local r,e = red.connect(conn.host, conn.port)
  if e then print(' ERROR: ', e, ' while connecting to: ', conn.host, conn.port); return nil end
  if conn.pass then assert(r:auth(conn.pass)) end
  if conn.db then assert(r:select(conn.db)) end
  return r
end
