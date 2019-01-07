_ = require 'lodash'
accessor = require '../expr/accessor'

re = /([a-zA-Z0-9]+)(?:\[([0-9]+)\])?/

parsePath = (str) ->
  segments = str.split('.')
  
  { set, get, descriptor } = accessor.of(str)
    
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

  { set, get, describe, descriptor }    


module.exports = 

  # Parse binding expressions (the expression you pass to the `bind` operation.)
  parseExpr: (opts...) ->
    switch opts.length
      when 1 
        console.info 'Calling', opts[0]
        parsePath(opts[0])
      when 2
        [ get, set ] = opts
        { get, set }    

  extractValue: (meta, obj) ->
    value =  meta.bind?.get?(obj) or meta.value
    if not value?
      if meta.required then throw new Error("Missing required attribute#{ if meta.name? then " '" + meta.name + "'" else ""}")
    value
    
  

