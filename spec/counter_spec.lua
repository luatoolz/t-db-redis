describe("counter", function()
  local t, counter
  setup(function()
    t = require "t"
    require "t.storage.redis.connection"
    t.env.REDIS_HOST='127.0.0.1'
    counter = t.storage.redis.counter.some
  end)
  it("type", function()
    assert.is_table(counter)
    assert.is_table(getmetatable(counter))
    local q = require "t.storage.redis.counter"
    assert.equal('t/storage/redis/counter', t.type(q))
--    assert.is_nil(q())
  end)
  it("operands", function()
    assert.equal('some', tostring(counter))
    assert.equal(0, tonumber(counter))
    assert.equal(1, counter + 1)
    assert.equal(1, tonumber(counter))
    assert.equal(2, counter + true)
    assert.equal(2, tonumber(counter))
    assert.equal(7, counter + 5)
    assert.equal(7, tonumber(counter))
    assert.equal(2, counter + (-5))
    assert.equal(2, tonumber(counter))
    assert.equal(0, -counter)
  end)
  it("__div", function()
--     assert.equal('some:deep', tostring(counter/'deep'))
  end)
end)
