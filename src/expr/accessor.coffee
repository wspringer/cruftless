parse = require './parse'
_ = require 'lodash'

accessor = (gen, desc) -> (key) ->
  set: (obj, value) -> obj[key] = value
  get: (obj) -> obj[key]
  getOrCreate: (obj) -> 
    if obj[key]? then obj[key]
    else 
      value = gen()
      obj[key] = value
      value
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
      context = _.reduce(_.initial(segments), (acc, segment) ->
        segment.getOrCreate(acc)
      , obj)
      _.last(segments).set(context, value)

    get: (obj) ->
      _.reduce(segments, (acc, segment) ->
        segment.get(acc)
      , obj)

    descriptor: (type = { type: 'any' }) ->
      _.chain(segments)
      .reverse()
      .reduce((acc, segment) ->
        segment.describe(acc)
      , type) 
      .value()

      




