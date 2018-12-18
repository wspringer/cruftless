build = require '../../src/model/builder'
XMLSerializer = require('xmldom').XMLSerializer

render = (node) ->
  new XMLSerializer().serializeToString(node)


describe 'the builder', ->

  it 'should allow you to build a model from XML', ->
    xml = '<foo><bar/></foo>'
    expect(render(build(xml).generate())).toEqual xml

  it 'should allow you to build a model from XML with attributes', ->
    xml = '<foo a="3"><bar/></foo>'
    expect(render(build(xml).generate())).toEqual xml

  it 'should allow you to build a model from XML with text content', ->
    xml = '<foo>bar</foo>'
    expect(render(build(xml).generate())).toEqual xml

  it 'should handle default namespaces okay', ->
    xml = '<foo xmlns="http://eastpole.nl/"><bar/></foo>'
    expect(render(build(xml).generate())).toEqual xml

  it 'should handle namespaces on attributes correctly', ->
    xml = '<foo xmlns:bar="http://eastpole.nl/" bar:bar="baz"/>'
    expect(render(build(xml).generate())).toEqual xml

  it 'should handle expressions correctly', ->
    xml = '<foo>{{bar}}</foo>'
    expect(render(build(xml).generate(bar: 3))).toEqual '<foo>3</foo>'

  it 'should handle expressions in attributes correctly', ->
    xml = '<foo a="{{a}}"/>'
    expect(render(build(xml).generate(a: 3))).toEqual '<foo a="3"/>'    

  it 'should handle modifiers correctly', ->        
    xml = '<foo>{{bar|required}}</foo>'
    expect(-> render(build(xml).generate())).toThrowError()

  it 'should allow you to bind elements too', ->
    xml = '''
    <foo xmlns:c="https://github.com/wspringer/cruftless" c:bind="a">
      <bar>{{b}}</bar>
    </foo>
    '''
    expect(render(build(xml).generate(a: b: 3)).replace(/\s/g, '')).toEqual "<foo><bar>3</bar></foo>"

  it 'should support a short syntax for binding elements', ->
    xml = '''
    <foo c-bind="a">
      <bar>{{b}}</bar>
    </foo>
    '''
    expect(render(build(xml).generate(a: b: 3)).replace(/\s/g, '')).toEqual "<foo><bar>3</bar></foo>"

  it 'should support arrays', ->
    xml = '<foo><bar c-bind="a|array" t="{{b}}"/></foo>'
    expect(render(build(xml).generate(a: [ { b: 3 }, { b: 4 }]))).toEqual '<foo><bar t="3"/><bar t="4"/></foo>'
    
  it 'should support arrays', ->
    xml = '<foo><bar c-bind="a|array">{{b}}</bar></foo>'
    expect(render(build(xml).generate(a: [ { b: 3 }, { b: 4 }]))).toEqual '<foo><bar>3</bar><bar>4</bar></foo>'
    