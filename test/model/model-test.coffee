{ element, attr, text } = require('../../src/cruftless')()

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
    expect(element('foo').toXML()).toEqual '<foo/>'
    expect(element('foo').ns('http://eastpole.nl/').toXML()).toEqual '<foo xmlns="http://eastpole.nl/"/>'
        
describe 'the entire model', ->


  it 'should allow you to construct an element with attributes', ->
    el = element('foo').attrs(
      attr('bar')
    )
    expect(el.toXML()).toEqual('<foo bar="bar"/>')
    el = element('foo').attrs(
      attr('bar').ns("http://www.eastpole.nl/")
    )
    expect(el.toXML()).toEqual('<foo xmlns="http://www.eastpole.nl/\" bar="bar"/>')

  it 'should allow you to construct an element with nested content', ->
    el = element('foo').content(
      element('bar')
    )
    expect(el.toXML()).toEqual('<foo><bar/></foo>')

  it 'should allow you to construct an element with nested elements with attributes', ->
    el = element('foo').content(
      element('bar').attrs(
        attr('bar')
      )
    )    
    expect(el.toXML()).toEqual("<foo><bar bar=\"bar\"/></foo>")

  it 'should allow you to construct an element with an attribute with a value', ->
    el = element('foo').attrs(
      attr('bar').value('zaz')
    )  
    expect(el.toXML()).toEqual("<foo bar=\"zaz\"/>")

  it 'should allow you to construct an element with an attribute with a reference', ->
    el = element('foo').attrs(
      attr('bar').bind('a')
    )    
    expect(el.toXML({ a: 'tree' })).toEqual('<foo bar="tree"/>')

  it 'should allow you to construct an element with an attribute with a nested reference', ->
    el = element('foo').attrs(
      attr('bar').bind('a.b.c')
    )    
    expect(el.toXML(a: b: c: 4)).toEqual('<foo bar="4"/>')    

  it 'should fail over a missing attribute value', ->
    el = element('foo').attrs(
      attr('bar').required()
    )
    expect(-> el.toXML()).toThrowError("Missing required attribute 'bar'")

  it 'should fail over a missing property', ->
    el = element('foo').attrs(
      attr('bar').bind('a').required()
    ) 
    expect(-> el.toXML({})).toThrow("Missing required attribute 'bar'")

  it 'should support nested text', ->
    el = element('foo').content(
      text().value('foo')
    )
    expect(el.toXML()).toEqual('<foo>foo</foo>')

  it 'should support nested text based on binding expr', ->
    el = element('foo').content(
      text().bind('a.b.c').required()
    )
    expect(el.toXML(a:b:c: 3)).toEqual('<foo>3</foo>')    

  it 'should allow you to extract an attribute value from an element', ->
    el = element('foo').attrs(
      attr('bar').bind('a.b.c')
    )    
    extracted = el.fromXML("<foo bar='3'/>")
    expect(extracted).toHaveProperty('a')
    expect(extracted.a).toHaveProperty('b')
    expect(extracted.a.b).toHaveProperty('c', '3')

  it 'should allow you to extract an attribute value from a nested element', ->
    el = element('foo').content(
      element('bar').attrs(
        attr('baz').bind('a')
      )
    )    
    extracted = el.fromXML("<foo><bar baz='3'/></foo>")
    expect(extracted).toHaveProperty('a', '3')

  it 'should allow you to extract text from nested element', ->
    el = element('foo').content(
      text().bind('a')
    )
    extracted = el.fromXML("<foo>3</foo>")   
    expect(extracted).toHaveProperty('a', '3')

  it 'should deal with many occurences', ->
    el = element('foo').content(
      element('bar').bind('values').array().attrs(
        attr('baz').bind('value')
      )
    )
    extracted = el.fromXML("<foo><bar baz='1'/><bar baz='2'/></foo>")
    expect(extracted).toHaveProperty('values')
    expect(extracted.values).toContainEqual(value: '1')
    expect(extracted.values).toContainEqual(value: '2')

  it 'should deal with many occurences with nested content', ->
    el = element('foo').content(
      element('bar').bind('values').array().attrs(
        attr('baz').bind('value.first')
      )
    )
    extracted = el.fromXML("<foo><bar baz='1'/><bar baz='2'/></foo>")
    expect(extracted).toHaveProperty('values')
    expect(extracted.values).toContainEqual(value: first: '1')
    expect(extracted.values).toContainEqual(value: first: '2')

  it 'should support rendering something supporting multiple elements', ->
    el = element('foo').content(
      element('bar').bind('values').array().attrs(
        attr('baz').bind('value')
      )
    )
    expect(el.toXML(values: [
      { value: '1' }
      { value: '2' }
    ])).toEqual('<foo><bar baz="1"/><bar baz="2"/></foo>')

  it 'should support nested objects', ->
    el = element('foo').bind('a').content(
      element('bar').bind('b').content(
        text().bind('c')
      )
    )
    extracted = el.fromXML("<foo><bar>zoom</bar></foo>")
    expect(extracted).toEqual(a:b:c: 'zoom')
    expect(el.toXML(extracted)).toEqual('<foo><bar>zoom</bar></foo>')

  it 'should support different types of values', ->
    el = element('foo').content(
      text().integer().bind('a')
    )
    extracted = el.fromXML("<foo>3</foo>")
    expect(extracted).toHaveProperty('a')
    expect(typeof extracted.a).toEqual 'number'

  it 'should return a type definition', ->
    el = element('foo').content(
      text().integer().bind('a')
    ) 
    expect(el.describe()).toEqual({ type: 'object', keys: { a: { type: 'integer' }}})

  it 'should return a type definition in nested object situations', ->
    el = element('foo').bind('c').content(
      text().integer().bind('a')
    ) 
    expect(el.describe()).toEqual({ type: 'object', keys: {"c": {"keys": {"a": {"type": "integer"}}, "type": "object"}}})

  it 'should return a type definition in nested array situations', ->
    el = element('foo').bind('c').array().content(
      text().integer().bind('a')
    ) 
    expect(el.describe()).toEqual({ type: 'object', keys: {"c": {type: 'array', "element": { type: 'object', keys: {"a": {"type": "integer"}}}}}})

  it 'should handle complicated situations well', ->
    el = element('foo').bind('a').content(
      element('bar').bind('b.c').content(
        element('zaz').content(text().bind('d'))        
      )
      element('baz').content(
        text().bind('b.c.e')
      )
    )
    expect(el.describe()).toEqual({"keys": {"a": {"keys": {"b": {"keys": {"c": {"keys": {"d": {"type": "string"}, "e": {"type": "string"}}, "type": "object"}}, "type": "object"}}, "type": "object"}}, "type": "object"})

  it 'should handle nested unbound elements', ->
    el = element('foo').content(
      element('bar').content(
        element('baz').content(
          text().bind('a')
        )
      )
    )
    expect(el.describe()).toEqual({ type: 'object', keys: {"a": {"type": "string"}}})

  it 'should handle conditionals', ->
    el = element('foo').content(
      element('bar').if('a').content(
        text().bind('a')
      )
    )
    expect(el.toXML()).toEqual('<foo/>')

  it 'should factor in conditionals in describing the model', ->
    el = element('foo').content(
      element('bar').if('b').content(
        text().bind('a')
      )
    )      
    expect(el.describe()).toEqual({ type: 'object', keys: { a: { type: 'string' }, b: { type: 'any' }}})

  it 'should be able to handle booleans', ->
    el = element('foo').content(
      text().bind('a').boolean()
    )
    expect(el.toXML({ a: true })).toEqual('<foo>true</foo>')
    expect(el.fromXML('<foo>true</foo>')).toEqual({ a: true })  


    