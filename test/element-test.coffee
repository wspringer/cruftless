{ element } = require '../src/model/element'

describe 'element', ->

  it 'should allow you to construct the meta data for an element', ->
    el = element('foo')
    expect(el).not.toBeNull()
    expect(el).toHaveProperty('ns')
    
    