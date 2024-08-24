describe("cache", function()
  local t, cache, iter
  setup(function()
    t = require "t"
    require "t.storage.redis.connection"
    t.env.REDIS_HOST='127.0.0.1'
    cache = t.storage.redis.cache.some
    iter = table.iter
  end)
  it("env", function()
    assert.equal('127.0.0.1', t.env.REDIS_HOST)
  end)
  it("type", function()
    assert.is_table(cache)
    assert.is_table(getmetatable(cache))
    local q = require "t.storage.redis.cache"
    assert.equal('t/storage/redis/cache', t.type(q))
    assert.is_nil(q())
    assert.equal('some', tostring(cache))
  end)
  it("__div", function()
    assert.equal('some:path', cache / 'path')
    assert.equal('some:path', cache / 'some:path')
  end)
  it("__sub", function()
    cache.any = 'suka'
    assert.equal('suka', cache.any)
    assert.is_nil((cache-'any').any)
  end)
  it("__newindex / __index", function()
    cache.anumber=nil
    cache.astring=nil
    cache.anobject=nil

    cache.anumber=4
    assert.equal(4, cache.anumber)
    cache.astring='string'
    assert.equal('string', cache.astring)
    cache.anobject={x=12,y='other',z={1,2,3,4},v={x=77,y='some'}}
    assert.same({x=12,y='other',z={1,2,3,4},v={x=77,y='some'}}, cache.anobject)

    cache.anobject2={'a','b','c','d'}
    assert.same({'a','b','c','d'}, cache.anobject2)

    assert.same(cache[''], cache['*'])
    assert.same(cache['*'], cache['*'])
    assert.same(cache[{}], cache['*'])
  end)
  it("__mod", function()
    assert.values({'other', 'another'}, (cache + {
      any='any_value', other='other_value', third=3} + {
      another='more_another'}) % '*ther')
  end)
  it("cache", function()
    assert.equal(0, tonumber(-cache))
    assert.same({}, table.map(cache))

--    cache['*']=nil
    cache.any=nil
    assert.equal(0, tonumber(cache))
    cache.any='any_value'
    assert.equal(1, tonumber(cache))
    cache.other='other_value'
    assert.equal(2, tonumber(cache))

    assert.values({'any', 'other'}, cache % '*')
    assert.values({'any', 'other'}, table.map(iter(cache)))
    assert.eq({any='any_value', other='other_value'}, cache)
    assert.eq({any='any_value', other='other_value', third=3}, cache + {third=3})

--    assert.equal('', cache % '*')
--    assert.equal('', cache['*'])
  end)
  it("__unm", function()
    assert.equal(0, tonumber(-cache))
    cache.any='any_value'
    assert.equal(1, tonumber(cache))
    cache.other='other_value'
    assert.equal(2, tonumber(cache))
    assert.equal(3, tonumber(cache + {another='more_another'}))
    assert.equal(0, tonumber(-cache))
  end)
end)
