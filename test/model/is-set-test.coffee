{ attr, element, text } = require('../../src/cruftless')()

describe 'the isSet method', ->

  it 'should return true for non-bound element', ->
    expect(element('foo').isSet()).toBeTruthy()

  it 'should return true for nested non-bound elements', ->
    expect(element('foo').content(
      element('bar')
    ).isSet()).toBeTruthy()

  it 'should return true for bound elements', ->
    el = element('foo').content(
      text().bind('a')
    )
    expect(el.isSet({ b: 3 })).toBeFalsy()
    expect(el.isSet({ a: 3 })).toBeTruthy()

  it 'should return true for bound attributes', ->
    el = element('foo').attrs(
      attr().bind('a')
    )    
    expect(el.isSet({ b: 3 })).toBeFalsy()
    expect(el.isSet({ a: 3 })).toBeTruthy()

  it 'should return true for nested bound attributes', ->
    el = element('foo').content(
      element('bar').attrs(
        attr().bind('a')
      )
    )
    expect(el.isSet({ b: 3 })).toBeFalsy()
    expect(el.isSet({ a: 3 })).toBeTruthy()

  it 'should return true for nested bound text', ->
    el = element('foo').content(
      element('bar').attrs(
        text().bind('a')
      )
    )
    expect(el.isSet({ b: 3 })).toBeFalsy()
    expect(el.isSet({ a: 3 })).toBeTruthy()

  it 'should return true if any of the elements is bound', ->
    el = element('foo').content(
      element('bar').content(
        text().bind('a')
      ),
      element('baz').content(
        text().bind('b')
      )
    )
    expect(el.isSet({ b: 3 })).toBeTruthy()

  it 'should return true if all of the elements are bound', ->
    el = element('foo').content(
      element('bar').content(
        text().bind('a')
      ),
      element('baz').content(
        text().bind('b')
      )
    )
    expect(el.isSet({ b: 3, a: 2 })).toBeTruthy()    
