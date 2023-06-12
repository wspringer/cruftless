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

    getName: ->
      meta.name

    getValue: ->
      meta.value

    generate: (obj, elem) ->
      value = extractValue(meta, obj)
      if value?
        if meta.ns?
          if meta.ns isnt 'http://www.w3.org/2000/xmlns/'
            elem.setAttributeNS(meta.ns, meta.name, meta.valueType.to(value))
          else
            elem.setAttributeNS(meta.ns, meta.name, meta.valueType.to(value))
        else
          elem.setAttribute(meta.name, meta.valueType.to(value))

    extract: (elem, target, raw) ->

      if meta.bind?
        value =
          if meta.ns?
            elem.getAttributeNS(meta.ns, meta.name)
          else
            elem.getAttribute(meta.name)
        decoded = if raw then value else meta.valueType.from(value)
        if value? then meta.bind.set(target, decoded)

    descriptor: ->
      meta.bind?.descriptor(_.merge({}, meta.valueType.desc, sample: if meta.sample? then meta.valueType.from(meta.sample)))

    isSet: (obj) ->
      not(meta.bind) or meta.bind.get(obj)?

    definedOn: (elem) ->
      # Another hack. We need to start remembering the prefix and local name during parsing.
      localName = _.last(meta.name.split(':'))
      result =
        if meta.ns?
          elem.hasAttributeNS(meta.ns, localName) and (meta.bind? or elem.getAttributeNS(meta.ns, localName) is meta.value)
        else
          elem.hasAttribute(meta.name) and (meta.bind? or elem.getAttribute(meta.name) is meta.value)
      result

    relaxng: (ctx) ->
      data =
        if meta.value?
          ctx.element('value').content(ctx.text().value(meta.value))
        else
          meta.valueType.relaxng(ctx)
      nested = ctx.element('attribute').attrs(ctx.attr('name').value(meta.name)).content(data)

      # This is a bit of a hack. First of all, the prefix is known during parsing. We could have kept it.
      # Second: schemawise, it might have been better to use the RelaxNG "ns" attribute.
      # Third: It's a little fishy scan for ':' to see if an attribute is namespaced.

      if meta.ns and meta.name.indexOf(':') >= 0
        [prefix,] = meta.name.split(':')
        nested.attrs(ctx.attr("xmlns:#{prefix}").value(meta.ns))
      if meta.required
        nested
      else
        ctx.element('optional').content(nested)

  _.forEach types, (value, key) ->
    exposed[key] = ->
      meta.valueType = value
      exposed

  exposed




