DOMParser = require('xmldom').DOMParser
_ = require 'lodash'
binding = require './binding'
curlyNS = 'https://github.com/wspringer/cruftless'
xincludeNS = 'http://www.w3.org/2001/XInclude'

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

  parse = (node, resolve) ->
    switch node.nodeType
      when 1
        if node.namespaceURI is xincludeNS and node.localName is 'include' and resolve?
          href = node.getAttribute('href')
          if href?
            [xml, next] = resolve(href)
            if xml?
              return parse(new DOMParser().parseFromString(xml).documentElement, next)


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
          .map (node) -> parse(node, resolve)
          .filter _.negate(_.isUndefined)
        el.content(content...)

        attrs = []
        forAllAttributes(node, (item) ->
          if (item.namespaceURI is curlyNS and item.localName is 'bind') or (item.name is 'c-bind')
            binding.raw(item.value).apply(el)
          else if (item.namespaceURI is curlyNS and item.localName is 'if') or (item.name is 'c-if')
            binding.raw(item.value).apply(el, 'if')
          else if item.prefix is 'xmlns' and (item.value is curlyNS or item.value is xincludeNS)
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

  (xml, resolver) ->
    parse(new DOMParser().parseFromString(xml).documentElement, resolver)







