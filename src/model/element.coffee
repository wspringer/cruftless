serializer = new(require('xmldom').XMLSerializer)
di = new(require('xmldom').DOMImplementation)
parser = new(require('xmldom').DOMParser)
_ = require 'lodash'
{ identity } = require 'lodash'

{ parseExpr } = require './util'

module.exports = ({types, format = _.identity}) -> (name) ->
  meta =
    name: name
    attrs: []
    content: []
    required: true
    multiple: false
    scope: (target) -> target or {}
    traverse: (obj, iterator) -> iterator(obj)
    descriptor: ->
      concatenated = _.concat(
        meta.if?.descriptor()
        meta.attrs.map (item) -> item.descriptor()
        meta.content.map (item) -> item.descriptor()
      )
      _.merge(_.reject(concatenated, _.isUndefined)...)

  exposed =

    optional: () ->
      meta.required = false
      exposed

    attrs: (attr...) ->
      meta.attrs.push(attr...)
      exposed

    content: (elem...) ->
      meta.content.push(elem...)
      exposed

    isRequired: ->
      meta.required

    ns: (ns) ->
      if ns? then meta.ns = ns
      exposed

    bind: (opts...) ->
      meta.bind = parseExpr(opts...)
      exposed.object()

    if: (opts...) ->
      meta.if = parseExpr(opts...)
      exposed

    array: ->
      meta.multiple = true
      meta.scope = (target) ->
        coll = meta.bind.get(target)
        if coll?
          if Array.isArray(coll)
            scope = {}
            coll.push(scope)
            scope
          else throw new Error("Scope already assignd value of type #{typeof value}")
        else
          coll = []
          meta.bind.set(target, coll)
          scope = {}
          coll.push scope
          scope
      meta.traverse = (obj, iterator) ->
        coll = meta.bind.get(obj) or []
        coll.forEach iterator
      meta.descriptor = ->
        concatenated = _.concat(
          meta.if?.descriptor()
          meta.attrs.map (item) -> item.descriptor()
          meta.content.map (item) -> item.descriptor()
        )
        result = { type: 'array', element: _.merge(_.reject(concatenated, _.isUndefined)...) }
        if meta.bind?
          meta.bind.descriptor(result)
        else
          result
      exposed

    object: ->
      meta.scope = (target) ->
        scope = meta.bind.get(target)
        if scope?
          if typeof value is 'object' then value
          else throw new Error("Scope already assignd value of type #{typeof value}")
        else
          scope = {}
          meta.bind.set(target, scope)
          scope
      meta.traverse = (obj, iterator) ->
        iterator(meta.bind.get(obj))
      meta.descriptor = ->
        merged = _.merge(_.reject(_.concat(
          meta.if?.descriptor()
          meta.attrs.map (item) -> item.descriptor()
          meta.content.map (item) -> item.descriptor()
        ), _.isUndefined)...)
        if meta.bind?
          meta.bind.descriptor(merged)
        else
          merged
      exposed

    generate: (obj, context) ->
      doc = context?.ownerDocument or di.createDocument()
      meta.traverse obj, (item) ->
        if (not(meta.if?) or meta.if.get(item)?)
          el =
            if meta.ns?
              doc.createElementNS(meta.ns, meta.name)
            else
              doc.createElement(meta.name)
          meta.attrs.forEach (attr) ->
            attr.generate(item, el)
          meta.content.forEach (node) ->
            if node.isSet(item)
              node.generate(item, el)
          if context?
            context.appendChild(el)
            return
          else
            return el

    isSet: (obj) ->
      (_.isEmpty(meta.attrs) and _.isEmpty(meta.content)) or (
        checked = false
        meta.traverse obj, (item) ->
          checked = checked or _.some(meta.attrs.concat(meta.content), (x) -> x.isSet(item))
        checked
      )

    toDOM: (obj) -> exposed.generate(obj)

    toXML: (obj) ->
      format(serializer.serializeToString(exposed.generate(obj)))

    matches: (elem) ->
      elem.nodeType is 1 and elem.localName is meta.name and (
        not(meta.ns?) or meta.ns is elem.namespaceURI
      ) 

    extract: (elem, target = {}, raw = false) ->
      scope = meta.scope(target)
      meta.attrs.forEach (attr) ->
        attr.extract(elem, scope, raw)
      Array.from(elem.childNodes or []).forEach (child) ->
        match = meta.content.find (nodeDef) -> nodeDef.matches(child)
        match?.extract(child, scope, raw)
      target

    fromDOM: (elem, raw = false) -> exposed.extract(elem, {}, raw)

    fromXML: (str, raw = false) ->
      exposed.extract(parser.parseFromString(str).documentElement, {}, raw)

    name: () -> meta.name

    getAttribute: (name) ->
      meta.attrs.find((attr) -> attr.getName() is name)

    descriptor: ->
      meta.descriptor()

    describe: (obj) ->
      if obj?
        meta.describe(obj)
        obj
      else
        obj = {}
        meta.describe(obj)
        { type: 'object', keys: obj }

    relaxng: (ctx) ->
      required =
        if (meta.content?.length || 0) is 1
          meta.content[0].isRequired()
        else
          meta.required
      multiple = meta.multiple
      wrap = switch
        when required and multiple then ctx.element('oneOrMore').content
        when not required and multiple then ctx.element('zeroOrMore').content
        when not required and not multiple then ctx.element('optional').content
      wrap = wrap or identity
      el = ctx.element('element')
        .attrs(ctx.attr('name').value(meta.name))
        .content(
          ...meta.attrs.map((node) -> node.relaxng(ctx))
          ...meta.content.map((node) -> node.relaxng(ctx)).filter((node) -> node?)
        )
      if meta.ns
        if meta.name.indexOf(':') >= 0
          [prefix,] = meta.name.split(':')
          el.attrs(ctx.attr("xmlns:#{prefix}").value(meta.ns))
        else
          el.attrs(ctx.attr('ns').value(meta.ns))
      wrap(
        el
      )

  exposed








