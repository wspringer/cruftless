cruftless = require('../../src/cruftless')
{ parse } = cruftless()

describe 'the relaxng support', ->

  it 'should support the simple case', ->
    template = parse('''<foo><bar/></foo>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual(
      "<element name=\"foo\" xmlns=\"http://relaxng.org/ns/structure/1.0\"><element name=\"bar\"/></element>"
    )
