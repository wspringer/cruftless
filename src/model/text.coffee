{ parseExpr, extractValue } = require './util'

module.exports = ->
  
  meta = 
    required: false

  exposed = 

    required: ->
      meta.required = true
      exposed

    value: (value) ->
      meta.value = value
      exposed

    bind: (opts...) ->
      meta.bind = parseExpr(opts...)
      exposed

    build: (obj, doc) ->
      value = extractValue(meta, obj)
      doc.createTextNode(value)

    matches: (node) ->
      node.nodeType is Node.TEXT_NODE      

    extract: (node, target) ->
      meta.bind.set(target, node.textContent)

    
  exposed

