{ element, attr, text, parse } = require('../../src/cruftless')()

describe 'cruftless namespaces', ->


  describe 'when using the builder', ->

    it 'should allow you to bind namespaces to elements', ->
      expect(element('foo').ns('http://foo.bar').toXML()).toEqual('<foo xmlns="http://foo.bar"/>')

    it 'should allow you to bind attributes and elements to a namespace', ->
      el = element('foo').content(
        element('bar').attrs(
          attr('t:zaz').ns('http://foo.bar')
        ),
        element('t:zaz').ns('http://foo.bar')
      )
      expect(el.toXML()).toEqual('<foo><bar xmlns:t=\"http://foo.bar\" t:zaz=\"t:zaz\"/><t:zaz/></foo>')

      
  describe 'when parsing templates', ->

    it 'should correctly handle namespaces', ->
      xml = '<foo><bar xmlns:t=\"http://foo.bar\" t:zaz=\"t:zaz\"/><t:zaz/></foo>'
      expect(parse(xml).toXML()).toEqual(xml)        

    it 'should correctly handle default namespaces', ->
      xml = '<foo><bar xmlns=\"http://foo.bar\"><zaz/></bar></foo>'
      expect(parse(xml).toXML()).toEqual(xml)        

    it 'should ignore the cruftless namespace', ->
      xml = '<foo><bar xmlns:c="https://github.com/wspringer/cruftless" c:if="a">{{a}}</bar></foo>'
      template = parse(xml)
      expect(template.toXML()).toEqual('<foo/>')
      expect(template.toXML({ a: 4 })).toEqual('<foo><bar>4</bar></foo>')
      
