_ = require 'lodash'

module.exports = 

  parseExpr: (opts...) ->
    switch opts.length
      when 1 
        expr = opts[0]
        get: (obj) -> 
          _.get(obj, expr)
        set: (obj, value) -> _.set(obj, expr, value)
      when 2
        [ get, set ] = opts
        { get, set }    

  extractValue: (meta, obj) ->
    value =  meta.bind?.get?(obj) or meta.value
    if not(value?)
      if meta.required then throw new Error("Missing required attribute '#{meta.name}''")
    value
    

