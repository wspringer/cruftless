{ element, attr, text, parse } = require('../../src/cruftless')()

describe 'conditionals', ->

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
    expect(el.descriptor()).toEqual({ type: 'object', keys: { a: { type: 'string' }, b: { type: 'any' }}})

  it 'should be able to handle conditionals in templates', ->
    el = parse('''
    <foo><bar c-if="a">{{a.b}}</bar></foo>
    ''')
    expect(el.descriptor()).toEqual({"keys": {"a": {"keys": {"b": {"type": "string"}}, "type": "object"}}, "type": "object"})

