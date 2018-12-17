{ element, text, attr } = require '../src/model/model'
XMLSerializer = require('xmldom').XMLSerializer
DOMParser = require('xmldom').DOMParser

render = (node) ->
  new XMLSerializer().serializeToString(node)

parse = (str) ->  
  new DOMParser().parseFromString(str).documentElement  

describe 'element', ->


  it 'should allow you to construct the meta data for an element', ->
    el = element('foo')
    expect(el).not.toBeNull()

    expect(el).toHaveProperty('ns')
    expect(el.ns('foo')).toBe(el)

    expect(el).toHaveProperty('content')
    expect(typeof el.content).toEqual 'function'

    expect(el).toHaveProperty('attrs')
    expect(typeof el.attrs).toEqual 'function'


  it 'should allow you to build the dom of an element', ->
    expect(render(element('foo').build())).toEqual '<foo/>'
    expect(render(element('foo').ns('http://eastpole.nl/').build())).toEqual '<foo xmlns="http://eastpole.nl/"/>'
        


describe 'the entire model', ->


  it 'should allow you to construct an element with attributes', ->
    el = element('foo').attrs(
      attr('bar')
    )
    expect(render(el.build())).toEqual('<foo bar="bar"/>')
    el = element('foo').attrs(
      attr('bar').ns("http://www.eastpole.nl/")
    )
    expect(render(el.build())).toEqual('<foo xmlns="http://www.eastpole.nl/\" bar="bar"/>')

  it 'should allow you to construct an element with nested content', ->
    el = element('foo').content(
      element('bar')
    )
    expect(render(el.build())).toEqual('<foo><bar/></foo>')

  it 'should allow you to construct an element with nested elements with attributes', ->
    el = element('foo').content(
      element('bar').attrs(
        attr('bar')
      )
    )    
    expect(render(el.build())).toEqual("<foo><bar bar=\"bar\"/></foo>")

  it 'should allow you to construct an element with an attribute with a value', ->
    el = element('foo').attrs(
      attr('bar').value('zaz')
    )  
    expect(render(el.build())).toEqual("<foo bar=\"zaz\"/>")

  it 'should allow you to construct an element with an attribute with a reference', ->
    el = element('foo').attrs(
      attr('bar').bind('a')
    )    
    expect(render(el.build({ a: 'tree' }))).toEqual('<foo bar="tree"/>')

  it 'should allow you to construct an element with an attribute with a nested reference', ->
    el = element('foo').attrs(
      attr('bar').bind('a.b.c')
    )    
    expect(render(el.build(a: b: c: 4))).toEqual('<foo bar="4"/>')    

  it 'should fail over a missing attribute value', ->
    el = element('foo').attrs(
      attr('bar').required()
    )
    expect(-> render(el.build())).toThrowError("Missing required attribute 'bar'")

  it 'should fail over a missing property', ->
    el = element('foo').attrs(
      attr('bar').bind('a').required()
    ) 
    expect(-> render(el.build({}))).toThrow("Missing required attribute 'bar'")

  it 'should support nested text', ->
    el = element('foo').content(
      text().value('foo')
    )
    expect(render(el.build())).toEqual('<foo>foo</foo>')

  it 'should support nested text based on binding expr', ->
    el = element('foo').content(
      text().bind('a.b.c').required()
    )
    expect(render(el.build(a:b:c: 3))).toEqual('<foo>3</foo>')    

  it 'should allow you to extract an attribute value from an element', ->
    el = element('foo').attrs(
      attr('bar').bind('a.b.c')
    )    
    extracted = el.extract(parse("<foo bar='3'/>"))
    expect(extracted).toHaveProperty('a')
    expect(extracted.a).toHaveProperty('b')
    expect(extracted.a.b).toHaveProperty('c', '3')

  it 'should allow you to extract an attribute value from a nested element', ->
    el = element('foo').content(
      element('bar').attrs(
        attr('baz').bind('a')
      )
    )    
    extracted = el.extract(parse("<foo><bar baz='3'/></foo>"))
    expect(extracted).toHaveProperty('a', '3')

  it 'should allow you to extract text from nested element', ->
    el = element('foo').content(
      text().bind('a')
    )
    extracted = el.extract(parse("<foo>3</foo>"))    
    expect(extracted).toHaveProperty('a', '3')


  
