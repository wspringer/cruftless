_ = require 'lodash'
{ parseExpr, extractValue } = require './util'
types = require './types'

module.exports = ({types}) -> (name) ->
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
      meta.required = true
      exposed

    sample: (value) ->
      meta.sample = value
      exposed

    generate: (obj, elem) ->
      value = extractValue(meta, obj)
      if value?
        if meta.ns?
          elem.setAttributeNS(meta.ns, meta.name, value)
        else
          elem.setAttribute(meta.name, value)

    extract: (elem, target, raw) ->
      if meta.bind?
        value =
          if meta.ns?
            elem.getAttributeNS(meta.ns, meta.name)
          else
            elem.getAttribute(meta.name)
        decoded = if raw then value else meta.valueType.from(value)
        if value? then meta.bind.set(target,decoded)

    descriptor: ->
      meta.bind?.descriptor(_.merge({}, meta.valueType.desc, sample: if meta.sample? then meta.valueType.from(meta.sample)))

    isSet: (obj) ->
      not(meta.bind) or meta.bind.get(obj)?

    definedOn: (elem) ->
      if meta.ns?
        elem.hasAttributeNS(meta.name) and (meta.bind? or elem.getAttributeNS(meta.name) is meta.value)
      else
        elem.hasAttribute(meta.name) and (meta.bind? or elem.getAttribute(meta.name) is meta.value)

    relaxng: (ctx) ->
      data =
        if meta.value?
          ctx.element('value').content(ctx.text().value(meta.value))
        else
          meta.valueType.relaxng(ctx)
      nested = ctx.element('attribute').attrs(ctx.attr('name').value(meta.name)).content(data)
      if meta.required
        nested
      else
        ctx.element('optional').content(nested)

  _.forEach types, (value, key) ->
    exposed[key] = ->
      meta.valueType = value
      exposed

  exposed




