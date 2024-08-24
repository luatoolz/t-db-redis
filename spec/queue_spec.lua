describe("queue", function()
  local t, queue, inspect
  setup(function()
    t = require "t"
    require "t.storage.redis.connection"
    t.env.REDIS_HOST='127.0.0.1'
    queue = t.storage.redis.queue.some
    inspect=require 'inspect'
  end)
  before_each(function() _=-queue end)
  after_each(function() _=-queue end)
  it("type", function()
    assert.is_table(queue)
    assert.is_table(getmetatable(queue))
    local q = require "t.storage.redis.queue"
    assert.equal('t/storage/redis/queue', t.type(q))
    assert.is_nil(q())
  end)
  it("for", function()
    print(inspect(queue))
    assert.equal(0, tonumber(queue))
    assert.equal(1, tonumber(queue + 'any'))
    assert.equal(2, tonumber(queue + 'other'))
    assert.equal(2, tonumber(queue))
    assert.same({'any', 'other'}, table.map(queue))
    assert.equal(0, tonumber(-queue))
  end)
  it("__unm", function()
    assert.equal(0, tonumber(queue))
    assert.equal(1, tonumber(queue + 'any'))
    assert.equal(2, tonumber(queue + 'other'))
    assert.equal(0, tonumber(-queue))
  end)
  it("__eq", function()
    assert.equal(0, tonumber(-queue))
    assert.eq({'any'}, queue + 'any')
    assert.eq({'any', 'other'}, queue + 'any' + 'other')
  end)
end)
