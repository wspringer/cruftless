cruftless = require('../../src/cruftless')
{ element, attr, text, parse } = cruftless()

describe 'comment', ->

  it 'should allow you to insert comments in the output document', ->
    data = { name: 'John', age: 33 }
    template = parse('<doc><!--{{age}}--><person>{{name}}</person></doc>')
    expect(template.toXML(data)).toEqual('<doc><!--33--><person>John</person></doc>')

  it 'should leave non expression based comments alone', ->
    template = parse('<person><!--yay--></person>')
    expect(template.toXML({})).toEqual('<person><!--yay--></person>')
