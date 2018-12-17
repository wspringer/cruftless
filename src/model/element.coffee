di = new(require('xmldom').DOMImplementation)

module.exports = (name) ->
  meta = 
    name: name
    attrs: []
    content: []

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

  exposed








