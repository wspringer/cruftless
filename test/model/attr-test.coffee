{ element, attr, text, parse } = require('../../src/cruftless')()
{ DOMImplementation } = require('xmldom')

describe 'attributes', ->

  it 'should encode attributes into xml', ->
    template = parse('<foo><bar a="{{a}}"/></foo>')
    expect(template.toXML(a: 3)).toEqual '<foo><bar a="3"/></foo>'

  it 'should decode attributes from xml', ->
    template = parse('<foo><bar a="{{a}}"/></foo>')
    expect(template.fromXML('<foo><bar a="3"/></foo>')).toEqual a: '3'

  it 'should ommit empty attributes when decoding', ->
    a = attr('a').bind('zozo')
    doc = new DOMImplementation().createDocument()
    el = doc.createElement('foo')
    obj = {}
    a.extract(el, obj)
    expect(obj).toEqual {}
