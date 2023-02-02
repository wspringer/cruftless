{ parseExpr, extractValue } = require './util'
_ = require 'lodash'

module.exports = () -> () ->
  meta =
    required: false

  exposed =

    required: ->
      meta.required = true
      exposed

    isRequired: ->
      meta.required

    bind: (opts...) ->
      meta.bind = parseExpr(opts...)
      exposed

    matches: (node) -> true

    generate: (obj, context) ->
      nodes = extractValue(meta, obj)
      _.forEach nodes, (node) -> context.appendChild(node) if node
      return

    extract: (node, target, raw) ->
      if meta.bind?
        prev = meta.bind.get(target)
        prev = prev || []
        prev.push(node)
        meta.bind.set(target, prev)

    descriptor: ->
      meta.bind?.descriptor()

    isSet: (obj) ->
      meta.required or not(meta.bind) or not(_.isEmpty(meta.bind.get(obj)))

    relaxng: (ctx) ->
      ctx.element("ref").attrs(ctx.attr("name").value("any"))

  exposed
