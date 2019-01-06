_ = require 'lodash'
parse = require '../expr/parse'

re = /([a-zA-Z0-9]+)(?:\[([0-9]+)\])?/

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
      if acc[segment]? and acc[segment].type isnt 'any'
        acc[segment].keys
      else 
        obj = { type: 'object', keys: {} }
        acc[segment] = obj
        obj.keys
    , obj)
    last = _.last(segments)
    ptr = context[last]
    if type.type is 'object' and ptr?.type is 'object' 
      merged = {
        type: 'object'
        keys: _.merge({}, type.keys, ptr.keys)
      }
      context[last] = merged
    else
      context[last] = type unless context[last]? and type.type is 'any'

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
    
  

