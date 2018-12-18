expr = require '../../src/model/expr'

describe 'the expr parser', ->

  it 'should parse an expression correctly', ->
    expect(expr('{{a.b.c}}').parsed).toEqual ['a.b.c']

  it 'should consider an illegal expression to be undefined', ->
    expect(expr('foo').parsed).toBeUndefined()

  it 'should find modifiers', ->
    expect(expr('{{a.b.c|foo|bar}}').parsed).toEqual ['a.b.c', 'foo', 'bar']    

      