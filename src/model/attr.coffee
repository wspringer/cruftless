_ = require 'lodash'
{ parseExpr, extractValue } = require './util'
types = require './types'

module.exports = (types) -> (name) ->
  meta = 
    name: name
    required: false
    valueType: types.string

  exposed = 

    required: ->
      meta.required = true
      exposed

    ns: (ns) ->
      meta.ns = ns
      exposed            
  
    bind: (opts...) ->
      meta.bind = parseExpr(opts...) 
      exposed

    value: (value) ->
      meta.value = value
      exposed      

    generate: (obj, elem) ->
      value = extractValue(meta, obj) or meta.name
      if meta.ns?
        elem.setAttributeNS(meta.ns, meta.name, value)
      else 
        elem.setAttribute(meta.name, value)

    extract: (elem, target) ->
      if meta.bind?
        value = 
          if meta.ns?
            elem.getAttributeNS(meta.ns, meta.name)
          else 
            elem.getAttribute(meta.name)        
        if value? then meta.bind.set(target, meta.valueType.from(value))

    describe: (obj) ->
      meta.bind?.describe?(obj, meta.valueType.desc)      

    isSet: (obj) ->
      not(meta.bind) or meta.bind.get(obj)?

  _.forEach types, (value, key) -> 
    exposed[key] = -> 
      meta.valueType = value
      exposed    
    
  exposed




