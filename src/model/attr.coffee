_ = require 'lodash'
{ parseExpr, extractValue } = require './util'

module.exports = (name) ->
  meta = 
    name: name
    required: false

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

    add: (obj, elem) ->
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
        if value? then meta.bind.set(target, value)

  exposed




