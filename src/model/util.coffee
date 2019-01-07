_ = require 'lodash'
accessor = require '../expr/accessor'

re = /([a-zA-Z0-9]+)(?:\[([0-9]+)\])?/

parsePath = (str) ->
  segments = str.split('.')
  
  { set, get, descriptor } = accessor.of(str)
    
  { set, get, descriptor }    


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
    
  

