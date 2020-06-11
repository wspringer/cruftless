{ parseExpr, extractValue } = require './util'
_ = require 'lodash'
types = require './types'

module.exports = ({types, preserveWhitespace}) -> () ->

  meta =
    required: false
    valueType: types.string
    cdata: false

  exposed =

    cdata: ->
      meta.cdata = true
      exposed

    required: ->
      meta.required = true
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
      value = extractValue(meta, obj)
      node =
        if meta.cdata
          context.ownerDocument.createCDATASection(meta.valueType.to(value))
        else
          context.ownerDocument.createTextNode(meta.valueType.to(value))
      context.appendChild(node)
      return

    matches: (node) ->
      node.nodeType is 3 or node.nodeType is 4

    sample: (value) ->
      meta.sample = value
      exposed

    extract: (node, target, raw) ->
      meta.bind?.set(target, if raw then node.textContent else meta.valueType.from(node.textContent))

    descriptor: ->
      meta.bind?.descriptor(_.merge({}, meta.valueType.desc, sample: if meta.sample? then meta.valueType.from(meta.sample)))

    isSet: (obj) ->
      meta.required or not(meta.bind) or not(_.isUndefined(meta.bind.get(obj)))

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

