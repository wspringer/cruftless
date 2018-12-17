_ = require 'lodash'
{ parseExpr } = require './util'

module.exports = (name) ->
  self = @
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
      value =  meta.bind?.get?(obj) or meta.value
      if not(value?)
        if meta.required then throw new Error("Missing required attribute '#{meta.name}''")
        else value = meta.name # attribute behaviour
      if meta.ns?
        elem.setAttributeNS(meta.ns, meta.name, value)
      else 
        elem.setAttribute(meta.name, value)


  exposed




