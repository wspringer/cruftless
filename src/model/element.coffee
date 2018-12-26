serializer = new(require('xmldom').XMLSerializer)
di = new(require('xmldom').DOMImplementation)
parser = new(require('xmldom').DOMParser)

{ parseExpr } = require './util'

module.exports = (name) ->
  meta = 
    name: name
    attrs: []
    content: []
    scope: (target) -> target or {}
    traverse: (obj, iterator) -> iterator(obj)
    describe: (obj) -> 
      meta.if?.describe(obj, { type: 'any' })
      meta.attrs.forEach (item) -> item.describe(obj)
      meta.content.forEach (item) -> item.describe(obj)
      obj      

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
      meta.describe = (obj) ->
        res = { type: 'array', element: { type: 'object', keys: {} } }
        meta.if?.describe(obj, res)
        meta.attrs.forEach (item) -> item.describe(res.element.keys)
        meta.content.forEach (item) -> item.describe(res.element.keys)
        meta.bind.describe(obj, res)  
        res
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
      meta.describe = (obj) ->
        res = { type: 'object', keys: {} }
        meta.if?.describe(obj, res)
        meta.attrs.forEach (item) -> item.describe(res.keys)
        meta.content.forEach (item) -> item.describe(res.keys)
        meta.bind?.describe(obj, res)  
        res
      exposed

    generate: (obj, context) ->
      doc = context?.ownerDocument or di.createDocument()      
      meta.traverse obj, (item) ->
        if not(meta.if?) or meta.if.get(item)?
          el = 
            if meta.ns?
              doc.createElementNS(meta.ns, meta.name)
            else
              doc.createElement(meta.name)        
          meta.attrs.forEach (attr) -> attr.generate(item, el)              
          meta.content.forEach (node) -> node.generate(item, el)
          if context? 
            context.appendChild(el)
            return
          else 
            return el     
          
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
        match.extract(child, scope)
      target  

    fromDOM: (elem) -> exposed.extract(elem)  

    fromXML: (str) ->
      exposed.extract(parser.parseFromString(str).documentElement)
      
    describe: (obj) ->
      if obj?
        meta.describe(obj)
        obj
      else 
        obj = {}
        meta.describe(obj)
        { type: 'object', keys: obj }
      


  exposed








