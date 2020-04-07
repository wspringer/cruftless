DOMParser = require('xmldom').DOMParser
_ = require 'lodash'
binding = require './binding'
curlyNS = 'https://github.com/wspringer/cruftless'

forAllAttributes = (node, fn) ->
  i = 0
  length = node.attributes.length
  result = []
  while i <= length - 1
    result.push(fn(node.attributes[i]))
    i += 1
  result

module.exports = (opts) ->
  { element, attr, text } = opts

  parse = (node) ->
    switch node.nodeType
      when 1
        el = element(node.tagName)
        if node.namespaceURI then el.ns(node.namespaceURI)

        childNodes = Array.from(node.childNodes)

        commentNode = childNodes.find (node) -> node.nodeType is 8
        if commentNode?
          binding.raw(commentNode.textContent).apply(el)

        content =
          childNodes
          .map parse
          .filter _.negate(_.isUndefined)
        el.content(content...)

        attrs = []
        forAllAttributes(node, (item) ->
          if (item.namespaceURI is curlyNS and item.localName is 'bind') or (item.name is 'c-bind')
            binding.raw(item.value).apply(el)
          else if (item.namespaceURI is curlyNS and item.localName is 'if') or (item.name is 'c-if')
            binding.raw(item.value).apply(el, 'if')
          else if item.prefix is 'xmlns'
          else
            res = binding.curly(item.value).apply(attr(item.name))
            if item.namespaceURI then res.ns(item.namespaceURI)
            attrs.push(res)
        )
        el.attrs(attrs...)

        el
      when 3
        empty = /^\s*$/.test(node.textContent)
        if not(empty) then binding.curly(node.textContent).apply(text())
      when 4
        empty = /^\s*$/.test(node.textContent)
        if not(empty) then binding.curly(node.data).apply(text())

  (xml) ->
    parse(new DOMParser().parseFromString(xml).documentElement)







