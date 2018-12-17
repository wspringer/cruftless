di = new(require('xmldom').DOMImplementation)
{ parseExpr } = require './util'

module.exports = (name) ->
  meta = 
    name: name
    attrs: []
    content: []
    scope: (target) -> target or {}

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
      exposed

    build: (obj, doc = di.createDocument()) ->
      el = 
        if meta.ns?
          doc.createElementNS(meta.ns, meta.name)
        else
          doc.createElement(meta.name)        
      meta.attrs.forEach (attr) ->
        attr.add(obj, el)              
      meta.content.forEach (node) ->
        el.appendChild(node.build(obj, doc))
      el

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
    

  exposed








