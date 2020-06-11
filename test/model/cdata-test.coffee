cruftless = require('../../src/cruftless')
{ element, attr, text, parse } = cruftless()

describe 'cdata', ->

  it 'should parse cdata like text', ->
    template = parse('<name>{{name|cdata}}</name>')
    expect(template.fromXML('<name>Wilfred</name>')).toEqual({ name: 'Wilfred' })
    expect(template.fromXML('<name><![CDATA[Joe]]></name>')).toEqual({ name: 'Joe' })
    expect(template.toXML({ name: 'Bob' })).toEqual('<name><![CDATA[Bob]]></name>')
