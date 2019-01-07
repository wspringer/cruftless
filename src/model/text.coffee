{ parseExpr, extractValue } = require './util'
_ = require 'lodash'
types = require './types'

module.exports = (types) -> () ->
  
  meta = 
    required: false
    valueType: types.string

  exposed = 

    required: ->
      meta.required = true
      exposed

    value: (value) ->
      meta.value = value
      exposed

    bind: (opts...) ->
      meta.bind = parseExpr(opts...)
      exposed

    generate: (obj, context) ->
      value = extractValue(meta, obj)
      node = context.ownerDocument.createTextNode(meta.valueType.to(value))

    bind: (opts...) ->
      meta.bind = parseExpr(opts...)
      exposed

    generate: (obj, context) ->
      value = extractValue(meta, obj)
      node = context.ownerDocument.createTextNode(meta.valueType.to(value))
      context.appendChild(node)
      return

    matches: (node) ->
      node.nodeType is 3

    extract: (node, target) ->
      console.info 'TARGET', target, meta.bind.descriptor(meta.valueType.desc)
      obj = {}
      meta.bind.set(obj, 'Joe')
      console.info 'JOE', obj
      meta.bind.set(target, meta.valueType.from(node.textContent))

    describe: (obj) ->
      meta.bind?.describe?(obj, meta.valueType.desc)      

    isSet: (obj) ->
      meta.required or not(meta.bind) or meta.bind.get(obj)?
  
  _.forEach types, (value, key) -> 
    exposed[key] = -> 
      meta.valueType = value
      exposed    

  exposed

