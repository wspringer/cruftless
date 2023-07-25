serializer = new(require('xmldom').XMLSerializer)
di = new(require('xmldom').DOMImplementation)
parser = new(require('xmldom').DOMParser)
_ = require 'lodash'
{ identity } = require 'lodash'

{ parseExpr } = require './util'
{ xsiNS } = require '../ns'




module.exports = ({types, kindProperty, format = _.identity, prefixes}) -> (name) ->
  meta =
    name: name
    attrs: []
    content: []
    required: true
    multiple: false
    kind: undefined
    scope: (target) -> target or {}
    traverse: (obj, iterator) -> iterator(obj)
    descriptor: ->
      concatenated = _.concat(
        meta.if?.descriptor()
        meta.attrs.map (item) -> item.descriptor()
        meta.content.map (item) -> item.descriptor()
      )
      _.merge(_.reject(concatenated, _.isUndefined)...)

  ###
  This is a simple workaround for
  https://github.com/wspringer/cruftless/issues/60 If there *are* prefixes
  registered, it will try to rewrite the type to a canonical version of it,
  using a registered prefix. Otherwise, it will use the value of xsi:type as is.
  ###
  canonicalizedXsiType = (elem) ->
    qname = elem.getAttributeNS(xsiNS, 'type')
    if qname.indexOf(':') > 0
      [prefix, localName] = qname.split(':')
      ns = elem.lookupNamespaceURI(prefix)
      qualifier = Object.keys(prefixes).find (key) -> prefixes[key] is ns
      if qualifier?
        "#{qualifier}:#{localName}"
      else
        qname
    else
      qname


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

    kind: (kind) ->
      if kind? then meta.kind = kind
      exposed

    ns: (ns) ->
      if ns? then meta.ns = ns
      exposed

    bind: (opts...) ->
      meta.bind = parseExpr(opts...)
      exposed.object()

    if: (opts...) ->
      meta.if = parseExpr(opts...)
      exposed

    values: ->
      meta.multiple = true
      meta.scope = (target) ->
        coll = meta.bind.get(target)
        if not(Array.isArray(coll))
          coll = []
          meta.bind.set(target, coll)
        scope = {}
        index = coll.length
        Object.defineProperty scope, 'value',
          get: -> coll[index]
          set: (val) -> coll[index] = val
        scope
      meta.traverse = (obj, iterator) ->
        coll = meta.bind.get(obj) or []
        coll.forEach (x) -> iterator({ value: x })
      meta.descriptor = ->
        concatenated = _.concat(
          meta.if?.descriptor()
          meta.attrs.map (item) -> item.descriptor()
          meta.content.map (item) -> item.descriptor()
        )
        result = { type: 'array', element: _.merge(_.reject(concatenated, _.isUndefined)...).keys.value }
        if meta.bind?
          meta.bind.descriptor(result)
        else
          result
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
          else throw new Error("Expected array, got #{typeof coll}")
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
          else throw new Error("Scope already assigned value of type #{typeof value}")
        else
          scope = {}
          meta.bind.set(target, scope)
          scope
      meta.traverse = (obj, iterator) ->
        value = meta.bind.get(obj)
        if (value) then iterator(value)
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
        if (not(meta.if?) or meta.if.get(item)?) and (not(meta.kind?) or meta.kind is item?[kindProperty] or not(item?[kindProperty]?))
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
      ) and (_.isUndefined(meta.kind) or canonicalizedXsiType(elem) is meta.kind)

    extract: (elem, target = {}, raw = false) ->
      scope = meta.scope(target)
      meta.attrs.forEach (attr) ->
        attr.extract(elem, scope, raw)
      Array.from(elem.childNodes or []).forEach (child) ->
        match = meta.content.find (nodeDef) -> nodeDef.matches(child)
        match?.extract(child, scope, raw)
      if meta.kind
        scope[kindProperty] = meta.kind
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








