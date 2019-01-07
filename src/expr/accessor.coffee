parse = require './parse'
_ = require 'lodash'

accessor = (gen, desc) -> (key) ->
  set: (obj, value) -> obj[key] = value
  get: (obj) -> obj[key]
  getOrCreate: (obj, nextGen) -> 
    if obj[key]? then obj[key]
    else 
      value = nextGen()
      obj[key] = value
      value
  gen: gen    
  describe: (type) ->
    desc(key, type)

property = accessor(
  -> {}, 
  (key, type) -> { type: 'object', keys: { "#{key}": type }} 
)
element = accessor(
  -> [],
  (key, type) -> { type: 'array', element: type }
)

module.exports = 
  of: (expr) ->
    parsed = parse(expr)
    segments = parsed.map (segment) ->
      switch segment.type
        when 'element' then element(parseInt(segment.index))
        when 'property' then property(segment.key)
    
    set: (obj, value) ->
      context = _.reduce(_.initial(segments), (acc, segment, index) ->
        segment.getOrCreate(acc, segments[index + 1].gen)
      , obj)
      _.last(segments).set(context, value)

    get: (obj) ->
      _.reduce(segments, (acc, segment) ->
        if acc? then segment.get(acc)
      , obj)

    descriptor: (type = { type: 'any' }) ->
      _.chain(segments)
      .clone()
      .reverse()
      .reduce((acc, segment) ->
        segment.describe(acc)
      , type) 
      .value()

    describe: (target, type) ->
      _.merge(target, @descriptor(type))
      




