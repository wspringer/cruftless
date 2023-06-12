cruftless = require('../../src/cruftless')

{ parse } = cruftless()

describe 'the relaxng support', ->

  it 'should support the simple case', ->
    template = parse('''<foo><bar/></foo>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual(
      "<element name=\"foo\"><element name=\"bar\"/></element>"
    )

  it 'should handle collections correctly', ->
    template = parse('''<foo><bar><?bind elements|array?><baz/></bar></foo>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual(
      "<element name=\"foo\"><oneOrMore><element name=\"bar\"><element name=\"baz\"/></element></oneOrMore></element>"
    )

  it 'should support required text nodes', ->
    template = parse('''<foo>{{bar|required}}</foo>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual("<element name=\"foo\"><data type=\"string\"/></element>")

  it 'should support optional text nodes', ->
    template = parse('''<foo>{{bar}}</foo>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual("<optional><element name=\"foo\"><data type=\"string\"/></element></optional>")

  it 'should support typed text', ->
    template = parse('''<foo>{{bar|required|boolean}}</foo>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual("<element name=\"foo\"><data type=\"boolean\"/></element>")

  it 'should support attributes', ->
    template = parse('''<foo name="yay"/>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual('<element name=\"foo\"><attribute name=\"name\"><value>yay</value></attribute></element>')

  it 'should not break on comments', ->
    template = parse('''<foo><!--{{a}}--></foo>''')
    expect(-> template.relaxng(cruftless()).toXML()).not.toThrow()
    expect(template.relaxng(cruftless()).toXML()).toEqual('<optional><element name="foo"/></optional>')

  xit 'should forward namespaces', ->
    template = parse('''<foo xmlns:xsi="http://xsi.io"><bar xsi:type="SomeType"/></foo>''')
    expect(template.relaxng(cruftless()).toXML()).toMatchSnapshot()

  xit 'should handle prefixed namespaces', ->
    template = parse('''<foo:bar xmlns:foo="http://example.com/"></foo:bar>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual('<element name="foo:bar" xmlns:foo="http://example.com/"/>')

  xit 'should handle default namespaces', ->
    template = parse('''<foo xmlns="http://card.io"/>''')
    expect(template.relaxng(cruftless()).toXML()).toEqual('<element name="foo" ns="http://card.io"/>')
