{ parse } = require('../../src/template')()
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
    xml = '<foo><bar t="{{b}}"><!--a|array--></bar></foo>'
    expect(parse(xml).toXML(a: [ { b: 3 }, { b: 4 }])).toEqual '<foo><bar t="3"/><bar t="4"/></foo>'
  
  it 'should support conditionals', ->
    xml = '<foo><bar c-if="a">{{a}}</bar></foo>'
    expect(parse(xml).toXML()).toEqual '<foo/>'

  it 'should support conditionals with namespaces', ->
    xml = '<foo><bar xmlns:c="https://github.com/wspringer/cruftless" c:if="a">{{a}}</bar></foo>'    
    expect(parse(xml).toXML()).toEqual '<foo/>'
