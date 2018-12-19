di = new(require('xmldom').DOMImplementation)
{ parseExpr } = require './util'

module.exports = (name) ->
  meta = 
    name: name
    attrs: []
    content: []
    scope: (target) -> target or {}
    traverse: (obj, iterator) -> iterator(obj)
    describe: (obj) -> 
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
        res = { type: 'array', element: {} }
        meta.attrs.forEach (item) -> item.describe(res.element)
        meta.content.forEach (item) -> item.describe(res.element)
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
        meta.attrs.forEach (item) -> item.describe(res.keys)
        meta.content.forEach (item) -> item.describe(res.keys)
        meta.bind.describe(obj, res)  
        res
      exposed

    generate: (obj, context) ->
      doc = context?.ownerDocument or di.createDocument()      
      meta.traverse obj, (item) ->
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

    matches: (elem) ->
      elem.nodeType is Node.ELEMENT_NODE and elem.localName is meta.name and (
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
      
    describe: (obj = {}) ->
      meta.describe(obj)
      obj
      


  exposed








