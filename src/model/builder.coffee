DOMParser = require('xmldom').DOMParser
{ element, attr, text } = require './model'
_ = require 'lodash'
expr = require './expr'

forAllAttributes = (node, fn) ->
  i = 0
  length = node.attributes.length
  result = []
  while i <= length - 1 
    result.push(fn(node.attributes[i]))
    i += 1
  result

parse = (node) ->
  switch node.nodeType 
    when Node.ELEMENT_NODE
      el = element(node.localName)
      if node.namespaceURI then el.ns(node.namespaceURI)

      content = 
        Array.from(node.childNodes)
        .map parse
        .filter _.negate(_.isUndefined)
      el.content(content...)

      attrs = forAllAttributes(node, (item) ->
        res = expr(item.value).apply(attr(item.name))
        if item.namespaceURI then res.ns(item.namespaceURI)
        res
      )
      el.attrs(attrs...)

      el
    when Node.TEXT_NODE
      expr(node.textContent).apply(text())


module.exports = (xml) ->
  parse(new DOMParser().parseFromString(xml).documentElement)






 
