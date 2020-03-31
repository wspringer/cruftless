{ parseExpr, extractValue } = require './util'
_ = require 'lodash'
types = require './types'

module.exports = ({types, preserveWhitespace}) -> () ->

  meta =
    required: false
    valueType: types.string

  exposed =

    required: ->
      meta.required = true
      exposed

    value: (value) ->
      meta.value =
        if (preserveWhitespace) then value else _.trim(value)
      exposed

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

    sample: (value) ->
      meta.sample = value
      exposed

    extract: (node, target) ->
      meta.bind?.set(target, meta.valueType.from(node.textContent))

    descriptor: ->
      meta.bind?.descriptor(_.merge({}, meta.valueType.desc, sample: if meta.sample? then meta.valueType.from(meta.sample)))

    isSet: (obj) ->
      meta.required or not(meta.bind) or not(_.isUndefined(meta.bind.get(obj)))

  _.forEach types, (value, key) ->
    exposed[key] = ->
      meta.valueType = value
      exposed

  exposed

