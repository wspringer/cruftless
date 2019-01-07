parse = require '../../src/expr/parse'

describe 'the expression parser', ->

  it 'should parse `foo` correctly', ->
    expect(parse('foo')).toEqual([{type: 'property', key: 'foo'}])

  it 'should parse `foo.bar` correctly', ->
    expect(parse('foo.bar')).toEqual([
      { type: 'property', key: 'foo' },
      { type: 'property', key: 'bar' }
    ])    

  it 'should parse `foo[0]` correctly', ->
    expect(parse('foo[0]')).toEqual([
      { type: 'property', key: 'foo' },
      { type: 'element', index: '0' }
    ]) 

  it 'should parse `foo[0][1]` correctly', ->
    expect(parse('foo[0][1]')).toEqual([
      { type: 'property', key: 'foo' },
      { type: 'element', index: '0' },
      { type: 'element', index: '1' }
    ])

  it 'should parse `[12]` correctly', ->
    expect(parse('[12]')).toEqual([
      { type: 'element', index: '12' }
    ])

  it 'should parse `a.b.c` correctly', ->
    expect(parse('a.b.c')).toEqual([
      { type: 'property', key: 'a' },
      { type: 'property', key: 'b' },
      { type: 'property', key: 'c' }
    ])

  it 'should parse `a1.b2` correctly', ->    
    expect(parse('a1.b2')).toEqual([
      { type: 'property', key: 'a1' },
      { type: 'property', key: 'b2' }
    ])

  it 'should consider `0a` to be invalid', ->
    expect(-> parse('0a')).toThrowError()

  it 'should consider keys starting with a number invalid anywhere', ->
    expect(-> parse('a.b.0a')).toThrowError()

  it 'should only allow numbers as indexes (for now)', ->
    expect(-> parse('[a]')).toThrowError()

  it 'should fail on unfinished expressions', ->
    expect(-> parse('[')).toThrowError()
    expect(-> parse('[0')).toThrowError()
    expect(-> parse('a[')).toThrowError()

