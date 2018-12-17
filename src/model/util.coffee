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

