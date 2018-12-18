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
