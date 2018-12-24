DOMParser = require('xmldom').DOMParser
{ element, attr, text } = require './model'
_ = require 'lodash'
expr = require './expr'
curlyNS = 'https://github.com/wspringer/cruftless'

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
    when 1
      el = element(node.localName)
      if node.namespaceURI then el.ns(node.namespaceURI)

      content = 
        Array.from(node.childNodes)
        .map parse
        .filter _.negate(_.isUndefined)
      el.content(content...)

      attrs = []
      forAllAttributes(node, (item) ->
        if (item.namespaceURI is curlyNS) or (item.name is 'c-bind')
          expr.raw(item.value).apply(el)
        else if item.prefix is 'xmlns'
        else
          res = expr.curly(item.value).apply(attr(item.name))
          if item.namespaceURI then res.ns(item.namespaceURI)
          attrs.push(res)
      )
      el.attrs(attrs...)

      el
    when 3
      expr.curly(node.textContent).apply(text())


module.exports = (xml) ->
  parse(new DOMParser().parseFromString(xml).documentElement)






 
