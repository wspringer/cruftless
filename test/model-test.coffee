{ element, text, attr } = require '../src/model/model'
XMLSerializer = require('xmldom').XMLSerializer

render = (node) ->
  new XMLSerializer().serializeToString(node)

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
    expect(render(el.build())).toEqual('<foo bar="watte"/>')
    el = element('foo').attrs(
      attr('bar').ns("http://www.eastpole.nl/")
    )
    expect(render(el.build())).toEqual('<foo xmlns="http://www.eastpole.nl/\" bar="watte"/>')

  it 'should allow you to construct an element with nested content', ->
    el = element('foo').content(
      element('bar')
    )
    expect(render(el.build())).toEqual('<foo><bar/></foo>')

