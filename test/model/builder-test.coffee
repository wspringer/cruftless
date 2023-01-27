{ parse } = require('../../src/cruftless')()
XMLSerializer = require('xmldom').XMLSerializer

describe 'the builder', ->

  it 'should allow you to build a model from XML', ->
    xml = '<foo><bar/></foo>'
    expect(parse(xml).toXML()).toEqual xml

  it 'should allow you to build a model from XML with attributes', ->
    xml = '<foo a="3"><bar/></foo>'
    expect(parse(xml).toXML()).toEqual xml

  it 'should allow you to build a model from XML with text content', ->
    xml = '<foo>bar</foo>'
    expect(parse(xml).toXML()).toEqual xml

  it 'should handle default namespaces okay', ->
    xml = '<foo xmlns="http://eastpole.nl/"><bar/></foo>'
    expect(parse(xml).toXML()).toEqual xml

  it 'should handle namespaces on attributes correctly', ->
    xml = '<foo xmlns:bar="http://eastpole.nl/" bar:bar="baz"/>'
    expect(parse(xml).toXML()).toEqual xml

  it 'should handle expressions correctly', ->
    xml = '<foo>{{bar}}</foo>'
    expect(parse(xml).toXML(bar: 3)).toEqual '<foo>3</foo>'

  it 'should handle expressions in attributes correctly', ->
    xml = '<foo a="{{a}}"/>'
    expect(parse(xml).toXML(a: 3)).toEqual '<foo a="3"/>'

  it 'should handle modifiers correctly', ->
    xml = '<foo>{{bar|required}}</foo>'
    expect(-> parse(xml).toXML()).toThrowError()

  it 'should allow you to bind elements too', ->
    xml = '''
    <foo xmlns:c="https://github.com/wspringer/cruftless" c:bind="a">
      <bar>{{b}}</bar>
    </foo>
    '''
    expect(parse(xml).toXML(a: b: 3).replace(/\s/g, '')).toEqual "<foo><bar>3</bar></foo>"

  it 'should support a short syntax for binding elements', ->
    xml = '''
    <foo c-bind="a">
      <bar>{{b}}</bar>
    </foo>
    '''
    expect(parse(xml).toXML(a: b: 3).replace(/\s/g, '')).toEqual "<foo><bar>3</bar></foo>"

  it 'should support arrays', ->
    xml = '<foo><bar c-bind="a|array" t="{{b}}"/></foo>'
    expect(parse(xml).toXML(a: [ { b: 3 }, { b: 4 }])).toEqual '<foo><bar t="3"/><bar t="4"/></foo>'

  it 'should support arrays', ->
    xml = '<foo><bar c-bind="a|array">{{b}}</bar></foo>'
    expect(parse(xml).toXML(a: [ { b: 3 }, { b: 4 }])).toEqual '<foo><bar>3</bar><bar>4</bar></foo>'

  it 'should support comment syntax', ->
    xml = '<foo><bar t="{{b}}"><?bind a|array?></bar></foo>'
    expect(parse(xml).toXML(a: [ { b: 3 }, { b: 4 }])).toEqual '<foo><bar t="3"/><bar t="4"/></foo>'

  it 'should support conditionals', ->
    xml = '<foo><bar c-if="a">{{a}}</bar></foo>'
    expect(parse(xml).toXML()).toEqual '<foo/>'

  it 'should support samples', ->
    xml = '<foo>{{a|sample:something}}</foo>'
    expect(parse(xml).descriptor()).toEqual({"keys": {"a": {"sample": "something", "type": "string"}}, "type": "object"})

  it 'should support conditionals with namespaces', ->
    xml = '<foo><bar xmlns:c="https://github.com/wspringer/cruftless" c:if="a">{{a}}</bar></foo>'
    expect(parse(xml).toXML()).toEqual '<foo/>'

  it 'should handle CDATA', ->
    xml = '<foo><![CDATA[Bad <strong>stuff</strong>]]></foo>'
    expect(parse(xml).toXML()).toEqual "<foo>Bad &lt;strong>stuff&lt;/strong></foo>"

  it 'should allow you to capture a nodeset', ->
    template = parse('<foo><?capture a?></foo>')
    extracted = template.fromXML('<foo><bar/></foo>')
    expect(extracted.a).not.toBeNull()
    expect(extracted.a.length).toEqual 1
    expect(extracted.a[0].nodeName).toEqual 'bar'

  it 'should allow you to produce data using a capture', ->
    template = parse('<foo><?capture a?></foo>')
    extracted = template.fromXML('<foo><bar/></foo>')
    expect(template.toXML(extracted)).toEqual '<foo><bar/></foo>'

  it 'should allow you produce data using a self-constructed dom node', ->
    template = parse('<foo><?capture a?></foo>')
    data = { a: [ parse('<bar/>').toDOM()] }
    expect(template.toXML(data)).toEqual '<foo><bar/></foo>'

  it 'should preserve namespace declarations', ->
    template = parse('<foo:bar xmlns:foo="http://example.com/"/>')
    expect(template.toXML()).toEqual('<foo:bar xmlns:foo="http://example.com/"/>')
