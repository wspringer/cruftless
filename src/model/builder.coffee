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
  { element, attr, text, comment, capture } = opts

  parse = (node) ->
    switch node.nodeType
      when 1
        el = element(node.tagName)
        if node.namespaceURI then el.ns(node.namespaceURI)

        childNodes = Array.from(node.childNodes)

        piNode = childNodes.find (node) -> node.nodeType is 7
        if piNode? and piNode.target is 'bind'
          binding.raw(piNode.data).apply(el)
        if piNode? and piNode.target is 'capture'
          captured = capture()
          binding.raw(piNode.data).apply(captured)
          el.content(captured)

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
          else if item.prefix is 'xmlns' or item.name is 'xmlns'
            # ignore
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
      when 8
        empty = /^\s*$/.test(node.textContent)
        if not(empty) then binding.curly(node.textContent).apply(comment())

  (xml) ->
    parse(new DOMParser().parseFromString(xml).documentElement)







