{ parseExpr, extractValue } = require './util'
Joi = require 'joi'
_ = require 'lodash'
types = require './types'

module.exports = ->
  
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

    number: -> 
      meta.valueType = types.float
      exposed

    integer: -> 
      meta.valueType = types.integer
      exposed

    bind: (opts...) ->
      meta.bind = parseExpr(opts...)
      exposed

    generate: (obj, context) ->
      value = extractValue(meta, obj)
      node = context.ownerDocument.createTextNode(value)
      context.appendChild(node)
      return

    matches: (node) ->
      node.nodeType is Node.TEXT_NODE      

    extract: (node, target) ->
      meta.bind.set(target, meta.valueType.from(node.textContent))

    
  exposed

