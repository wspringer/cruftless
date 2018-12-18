DOMParser = require('xmldom').DOMParser
{ element, attr, text } = require './model'
_ = require 'lodash'

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
        res = attr(item.name).value(item.value)
        if item.namespaceURI then res.ns(item.namespaceURI)
        res
      )
      el.attrs(attrs...)

      el
    when Node.TEXT_NODE
      text().value(node.textContent)


module.exports = (xml) ->
  parse(new DOMParser().parseFromString(xml).documentElement)






 
