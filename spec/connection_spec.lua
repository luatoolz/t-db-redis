describe("connection", function()
  local t, is, conn
  setup(function()
    t = require "t"
    is = t.is
    conn = require "t.storage.redis.connection"
  end)
  it("connection", function()
    assert.is_function(conn)
    assert.truthy(conn())
    assert.not_nil(conn)
    assert.equal('t/storage/redis/connection', t.type(conn))
    assert.is_true(is.factory(conn))
    if os.getenv('REDIS_HOST') then
      assert.is_true(conn():ping())
    end
  end)
end)
