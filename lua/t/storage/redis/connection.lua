local t = require "t"
local env = t.env
local red = require "redis"

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
  local r = assert(red.connect(conn.host, conn.port))
  if conn.pass then assert(r:auth(conn.pass)) end
  if conn.db then assert(r:select(conn.db)) end
  return r
end
