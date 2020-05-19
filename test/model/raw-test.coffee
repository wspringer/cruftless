cruftless = require('../../src/cruftless')
{ element, attr, text, parse } = cruftless()

describe 'raw extraction', ->

  it 'should allow you to extract raw data', ->
    template = parse('<foo>{{a|integer}}</foo>')
    expect(template.fromXML('<foo>23</foo>')).toHaveProperty('a', 23)
    expect(template.fromXML('<foo>23</foo>', true)).toHaveProperty('a', '23')

  it 'should allow you to extract raw data in case of custom value types', ->
    { parse } = cruftless({
      types: {
        zeroOrOne: {
          type: 'boolean'
          from: (str) -> str is '1'
          to: (value) => if value? then '1' else '0'
        }
      }
    })
    template = parse('<foo>{{a|zeroOrOne}}</foo>')
    expect(template.fromXML('<foo>1</foo>')).toHaveProperty('a', true)
    expect(template.fromXML('<foo>1</foo>', true)).toHaveProperty('a', '1')
