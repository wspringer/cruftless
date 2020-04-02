cruftless = require('../../src/cruftless')
{ parse } = cruftless()

describe 'the relaxng support', ->

  it 'should support the simple case', ->
    template = parse('''<foo><bar/></foo>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual(
      "<element name=\"foo\"><element name=\"bar\"/></element>"
    )

  it 'should handle collections correctly', ->
    template = parse('''<foo><bar><!--elements|array--><baz/></bar></foo>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual(
      "<element name=\"foo\"><oneOrMore><element name=\"bar\"><element name=\"baz\"/></element></oneOrMore></element>"
    )

  it 'should support required text nodes', ->
    template = parse('''<foo>{{bar|required}}</foo>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual("<element name=\"foo\"><data type=\"string\"/></element>")

  it 'should support optional text nodes', ->
    template = parse('''<foo>{{bar}}</foo>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual("<element name=\"foo\"><optional><data type=\"string\"/></optional></element>")

  it 'should support typed text', ->
    template = parse('''<foo>{{bar|required|boolean}}</foo>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual("<element name=\"foo\"><data type=\"boolean\"/></element>")

  it 'should support attributes', ->
    template = parse('''<foo name="yay"/>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual('<element name=\"foo\"><attribute name=\"name\"><value>yay</value></attribute></element>')

