{ parseExpr, extractValue } = require './util'
_ = require 'lodash'
types = require './types'

module.exports = ({types, preserveWhitespace}) -> () ->

  meta =
    required: false
    valueType: types.string
    defaultValue: undefined

  exposed =

    required: ->
      meta.required = true
      exposed

    default: (value) ->
      meta.defaultValue = value
      exposed

    value: (value) ->
      meta.value = value
      meta.required = true
      exposed

    isRequired: ->
      meta.required

    bind: (opts...) ->
      meta.bind = parseExpr(opts...)
      exposed

    generate: (obj, context) ->
      extracted = extractValue(meta, obj)
      value =
        if extracted?
          extracted
        else
          meta.defaultValue
      if value?
        node = context.ownerDocument.createTextNode(meta.valueType.to(value))
        context.appendChild(node)
      return

    matches: (node) ->
      node.nodeType is 3

    sample: (value) ->
      meta.sample = value
      exposed

    extract: (node, target, raw) ->
      meta.bind?.set(target, if raw then node.textContent else meta.valueType.from(node.textContent))

    descriptor: ->
      meta.bind?.descriptor(_.merge({}, meta.valueType.desc, sample: if meta.sample? then meta.valueType.from(meta.sample)))

    isSet: (obj) ->
      meta.required or not(meta.bind) or not(_.isUndefined(meta.bind.get(obj))) or not(_.isUndefined(meta.defaultValue))

    relaxng: (ctx) ->
      if meta.value
        ctx.element('value').content(ctx.text(meta.value))
      else
        meta.valueType.relaxng(ctx)

  _.forEach types, (value, key) ->
    exposed[key] = ->
      meta.valueType = value
      exposed



  exposed

