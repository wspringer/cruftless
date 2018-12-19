_ = require 'lodash'

parsePath = (str) ->
  segments = str.split('.')
  
  set = (obj, value) ->
    context = _.reduce(_.initial(segments), (acc, segment) ->
      if acc[segment]? 
        acc[segment]
      else 
        obj = {}
        acc[segment] = obj
        obj
    , obj)
    context[_.last(segments)] = value
  
  get = (obj) ->
    _.reduce(segments, (acc, segment) ->
      if acc? then acc[segment]
    , obj)
  
  describe = (obj, type) ->
    context = _.reduce(_.initial(segments), (acc, segment) ->
      if acc[segment]? 
        acc[segment].keys
      else 
        obj = { type: 'object', keys: {} }
        acc[segment] = obj
        obj.keys
    , obj)
    context[_.last(segments)] = type

  { set, get, describe }  


module.exports = 

  # Parse binding expressions (the expression you pass to the `bind` operation.)
  parseExpr: (opts...) ->
    switch opts.length
      when 1 
        parsePath(opts[0])
      when 2
        [ get, set ] = opts
        { get, set }    

  extractValue: (meta, obj) ->
    value =  meta.bind?.get?(obj) or meta.value
    if not value?
      if meta.required then throw new Error("Missing required attribute#{ if meta.name? then " '" + meta.name + "'" else ""}")
    value
    
  

