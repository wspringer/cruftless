serializer = new(require('xmldom').XMLSerializer)
di = new(require('xmldom').DOMImplementation)
parser = new(require('xmldom').DOMParser)
_ = require 'lodash'

{ parseExpr } = require './util'

module.exports = (types) -> (name) ->
  meta = 
    name: name
    attrs: []
    content: []
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
  
    attrs: (attr...) -> 
      meta.attrs.push(attr...) 
      exposed

    content: (elem...) -> 
      meta.content.push(elem...)
      exposed

    ns: (ns) -> 
      meta.ns = ns
      exposed
      
    bind: (opts...) ->
      meta.bind = parseExpr(opts...) 
      exposed.object()     

    if: (opts...) ->
      meta.if = parseExpr(opts...)
      exposed      
  
    array: ->
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
          meta.attrs.forEach (attr) -> attr.generate(item, el)              
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
      serializer.serializeToString(exposed.generate(obj))      

    matches: (elem) ->
      elem.nodeType is 1 and elem.localName is meta.name and (
        not(meta.ns?) or meta.ns is elem.namespaceURI
      )

    extract: (elem, target = {}) ->    
      scope = meta.scope(target)  
      meta.attrs.forEach (attr) ->
        attr.extract(elem, scope)        
      Array.from(elem.childNodes).forEach (child) ->
        match = meta.content.find (nodeDef) -> nodeDef.matches(child) 
        if match?
          match.extract(child, scope)
        else
          console.error("Missing definition for `#{child.localName}`") unless match?               
      target  

    fromDOM: (elem) -> exposed.extract(elem)  

    fromXML: (str) ->
      exposed.extract(parser.parseFromString(str).documentElement)
      
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
      


  exposed








