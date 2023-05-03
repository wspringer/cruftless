cruftless = require('../../src/cruftless')
_ = require 'lodash'
{ element, attr, text, parse, capture, relaxng } = cruftless()

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
    expect(element('foo').toXML()).toEqual '<foo/>'
    expect(element('foo').ns('http://eastpole.nl/').toXML()).toEqual '<foo xmlns="http://eastpole.nl/"/>'

describe 'the entire model', ->


  it 'should allow you to construct an element with attributes', ->
    el = element('foo').attrs(
      attr('bar').value('bar')
    )
    expect(el.toXML()).toEqual('<foo bar="bar"/>')
    el = element('foo').attrs(
      attr('bar').ns("http://www.eastpole.nl/").value('bar')
    )
    expect(el.toXML()).toEqual('<foo xmlns="http://www.eastpole.nl/\" bar="bar"/>')

  it 'should allow you to construct an element with nested content', ->
    el = element('foo').content(
      element('bar')
    )
    expect(el.toXML()).toEqual('<foo><bar/></foo>')

  it 'should allow you to construct an element with nested elements with attributes', ->
    el = element('foo').content(
      element('bar').attrs(
        attr('bar').value('bar')
      )
    )
    expect(el.toXML()).toEqual("<foo><bar bar=\"bar\"/></foo>")

  it 'should allow you to construct an element with an attribute with a value', ->
    el = element('foo').attrs(
      attr('bar').value('zaz')
    )
    expect(el.toXML()).toEqual("<foo bar=\"zaz\"/>")

  it 'should allow you to construct an element with an attribute with a reference', ->
    el = element('foo').attrs(
      attr('bar').bind('a')
    )
    expect(el.toXML({ a: 'tree' })).toEqual('<foo bar="tree"/>')

  it 'should allow you to construct an element with an attribute with a nested reference', ->
    el = element('foo').attrs(
      attr('bar').bind('a.b.c')
    )
    expect(el.toXML(a: b: c: 4)).toEqual('<foo bar="4"/>')

  it 'should fail over a missing attribute value', ->
    el = element('foo').attrs(
      attr('bar').required()
    )
    expect(-> el.toXML()).toThrowError("Missing required attribute 'bar'")

  it 'should fail over a missing property', ->
    el = element('foo').attrs(
      attr('bar').bind('a').required()
    )
    expect(-> el.toXML({})).toThrow("Missing required attribute 'bar'")

  it 'should support nested text', ->
    el = element('foo').content(
      text().value('foo')
    )
    expect(el.toXML()).toEqual('<foo>foo</foo>')

  it 'should support nested text based on binding expr', ->
    el = element('foo').content(
      text().bind('a.b.c').required()
    )
    expect(el.toXML(a:b:c: 3)).toEqual('<foo>3</foo>')

  it 'should allow you to extract an attribute value from an element', ->
    el = element('foo').attrs(
      attr('bar').bind('a.b.c')
    )
    extracted = el.fromXML("<foo bar='3'/>")
    expect(extracted).toHaveProperty('a')
    expect(extracted.a).toHaveProperty('b')
    expect(extracted.a.b).toHaveProperty('c', '3')

  it 'should allow you to extract an attribute value from a nested element', ->
    el = element('foo').content(
      element('bar').attrs(
        attr('baz').bind('a')
      )
    )
    extracted = el.fromXML("<foo><bar baz='3'/></foo>")
    expect(extracted).toHaveProperty('a', '3')

  it 'should allow you to extract text from nested element', ->
    el = element('foo').content(
      text().bind('a')
    )
    extracted = el.fromXML("<foo>3</foo>")
    expect(extracted).toHaveProperty('a', '3')

  it 'should deal with many occurences', ->
    el = element('foo').content(
      element('bar').bind('values').array().attrs(
        attr('baz').bind('value')
      )
    )
    extracted = el.fromXML("<foo><bar baz='1'/><bar baz='2'/></foo>")
    expect(extracted).toHaveProperty('values')
    expect(extracted.values).toContainEqual(value: '1')
    expect(extracted.values).toContainEqual(value: '2')

  it 'should deal with many occurences with nested content', ->
    el = element('foo').content(
      element('bar').bind('values').array().attrs(
        attr('baz').bind('value.first')
      )
    )
    extracted = el.fromXML("<foo><bar baz='1'/><bar baz='2'/></foo>")
    expect(extracted).toHaveProperty('values')
    expect(extracted.values).toContainEqual(value: first: '1')
    expect(extracted.values).toContainEqual(value: first: '2')

  it 'should support rendering something supporting multiple elements', ->
    el = element('foo').content(
      element('bar').bind('values').array().attrs(
        attr('baz').bind('value')
      )
    )
    expect(el.toXML(values: [
      { value: '1' }
      { value: '2' }
    ])).toEqual('<foo><bar baz="1"/><bar baz="2"/></foo>')

  it 'should support nested objects', ->
    el = element('foo').bind('a').content(
      element('bar').bind('b').content(
        text().bind('c')
      )
    )
    extracted = el.fromXML("<foo><bar>zoom</bar></foo>")
    expect(extracted).toEqual(a:b:c: 'zoom')
    expect(el.toXML(extracted)).toEqual('<foo><bar>zoom</bar></foo>')

  it 'should support different types of values', ->
    el = element('foo').content(
      text().integer().bind('a')
    )
    extracted = el.fromXML("<foo>3</foo>")
    expect(extracted).toHaveProperty('a')
    expect(typeof extracted.a).toEqual 'number'

  it 'should return a type definition', ->
    el = element('foo').content(
      text().integer().bind('a')
    )
    expect(el.descriptor()).toEqual({ type: 'object', keys: { a: { type: 'integer' }}})

  it 'should return a type definition in nested object situations', ->
    el = element('foo').bind('c').content(
      text().integer().bind('a')
    )
    expect(el.descriptor()).toEqual({ type: 'object', keys: {"c": {"keys": {"a": {"type": "integer"}}, "type": "object"}}})

  it 'should return a type definition in nested array situations', ->
    el = element('foo').bind('c').array().content(
      text().integer().bind('a')
    )
    expect(el.descriptor()).toEqual({ type: 'object', keys: {"c": {type: 'array', "element": { type: 'object', keys: {"a": {"type": "integer"}}}}}})

  it 'should handle complicated situations well', ->
    el = element('foo').bind('a').content(
      element('bar').bind('b.c').content(
        element('zaz').content(text().bind('d'))
      )
      element('baz').content(
        text().bind('b.c.e')
      )
    )
    expect(el.descriptor()).toEqual({"keys": {"a": {"keys": {"b": {"keys": {"c": {"keys": {"d": {"type": "string"}, "e": {"type": "string"}}, "type": "object"}}, "type": "object"}}, "type": "object"}}, "type": "object"})

  it 'should handle nested unbound elements', ->
    el = element('foo').content(
      element('bar').content(
        element('baz').content(
          text().bind('a')
        )
      )
    )
    expect(el.descriptor()).toEqual({ type: 'object', keys: {"a": {"type": "string"}}})

  it 'should be able to handle booleans', ->
    el = element('foo').content(
      text().bind('a').boolean()
    )
    expect(el.toXML({ a: true })).toEqual('<foo>true</foo>')
    expect(el.fromXML('<foo>true</foo>')).toEqual({ a: true })

  it 'should not include nested elements if they\'re not bound', ->
    el = element('foo').content(
      element('bar').content(
        text().bind('a')
      )
    )
    expect(el.toXML()).toEqual('<foo/>')

  it 'should not include text if the variables are missing', ->
    el = element('foo').content(
      text().bind('a')
    )
    expect(el.toXML()).toEqual('<foo/>')

  it 'should not include nested elements if the variables are missing', ->
    el = element('foo').content(
      element('bar').content(
        text().bind('a')
      )
    )
    expect(el.toXML()).toEqual('<foo/>')

  it 'should not include nested elements with bound attributes if the variables are missing', ->
    el = element('foo').content(
      element('bar').attrs(
        attr('baz').bind('a')
      )
    )
    expect(el.toXML()).toEqual('<foo/>')
    expect(el.toXML({ a: 3 })).toEqual('<foo><bar baz="3"/></foo>')

  it 'should work with array annotations', ->
    el = element('foo').content(
      element('bar').attrs(
        attr('key').value('Person[1].Name')
      ).content(
        text().bind('persons[0].name')
      ).if('persons[0].name')
    )
    expect(el.toXML({ persons: [ { name: 'Joe' }] })).toEqual("<foo><bar key=\"Person[1].Name\">Joe</bar></foo>")
    expect(el.toXML({ persons: []})).toEqual("<foo/>")
    expect(el.fromXML el.toXML({ persons: [ { name: 'Joe' }] })).toEqual({ persons: [ { name: 'Joe' } ] })

  it 'should survive content getting passed in that is not matching', ->
    el = element('foo').content(
      element('bar').content(
        text().bind('a')
      )
    )
    expect(el.fromXML('<foo><zaz/></foo>')).toEqual({})

  it 'should not fail on this', ->
    source = '''<CustomerSignupRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" MajorVersion="2" MinorVersion="0">
    <Header>
      <MessageId>c74894f9-1030-41ac-9aae-cbc5e6ee69a0</MessageId>
    </Header></CustomerSignupRequest>'''
    el = parse(source)
    expect(el.fromXML(source)).toEqual({})

  it 'should not fail on this either', ->
    source = '''<DynamicAttributes>
    <KeyGroup>
        <Value key="opt-in">
            {{optIn}}
        </Value>
        <Value key="IdentifiedSince">
            {{since}}
        </Value>
    </KeyGroup></DynamicAttributes>'''
    el = parse(source)
    xml = el.toXML()
    expect(xml).toMatchSnapshot()
    expect(el.fromXML(xml)).toEqual({})
    xml = el.toXML({optIn : true})
    expect(xml).toMatchSnapshot()
    xml = el.toXML({optIn: 'True'})
    expect(xml).toMatchSnapshot()

  it 'should allow you bind to array elements', ->
    el = element('foo').content(
      text().bind('a.b[0]')
    )
    expect(el.fromXML('<foo>aa</foo>')).toEqual(a: b: [ 'aa' ])

  it 'should have the local name readily available', ->
    expect(parse('<foo/>').name()).toEqual('foo')

  it 'should be able to do that for currently failing cases', ->
    el = parse('''<KeyGroup>
      <Value key="Newsletter[1]">{{comm.newsLetter[0]|boolean}}</Value>
    </KeyGroup>''')
    xml = el.toXML(comm: newsLetter: [true])
    expect(el.fromXML(xml)).toEqual({"comm": {"newsLetter": [true]}})

  it 'should include elements with a false value', ->
    el = parse('''<foo><bar>{{a|boolean}}</bar></foo>''')
    expect(el.toXML({ a: true })).toEqual('<foo><bar>true</bar></foo>')
    expect(el.toXML({ a: false })).toEqual('<foo><bar>false</bar></foo>')

  # it 'should work simple', ->
  #   el = parse('''
  #   <foo>
  #     <bar c-bind="persons|array">{{name}}</bar>
  #     <baz c-bind="persons|array">{{name}}</baz>
  #   </foo>
  #   '''.trim())
  #   expect(el.toXML({ persons: [{ name: "Joe" }, { name: 'Peter'}] })).toEqual('<foo><bar>Joe</bar></foo>')

  it 'should allow you to capture anything', ->
    el = element('foo').content(
      capture().bind('a')
    )
    extracted = el.fromXML('<foo><baz/></foo>')
    expect(extracted).toHaveProperty('a')
    expect(_.isArray(extracted.a)).toBe(true)
    expect(extracted.a.length).toBe(1)
    expect(extracted.a[0]).toHaveProperty('nodeType', 1)
    expect(extracted.a[0]).toHaveProperty('tagName', 'baz')
    expect(el.toXML(extracted)).toEqual('<foo><baz/></foo>')
    expect(relaxng(el)).toMatchSnapshot()

  xit 'should be able to parse a template from the wild', ->
    el = parse('''
<catalog>
  <book id="{{id}}" c-bind="books|array">
    <author>{{author}}</author>
    <title>{{title}}</title>
    <genre>{{genre}}</genre>
    <price>{{price}}</price>
    <publish_date>{{publicationDate}}</publish_date>
    <description>{{desc}}</description>
  </book>
</catalog>
    ''')
    xml = '''
    <catalog>
       <book id="bk101">
          <author>Gambardella, Matthew</author>
          <title>XML Developer's Guide</title>
          <genre>Computer</genre>
          <price>44.95</price>
          <publish_date>2000-10-01</publish_date>
          <description>An in-depth look at creating applications
          with XML.</description>
       </book>
       <book id="bk102">
          <author>Ralls, Kim</author>
          <title>Midnight Rain</title>
          <genre>Fantasy</genre>
          <price>5.95</price>
          <publish_date>2000-12-16</publish_date>
          <description>A former architect battles corporate zombies,
          an evil sorceress, and her own childhood to become queen
          of the world.</description>
       </book>
    </catalog>
    '''
    expect(el.fromXML(xml)).toEqual({
      "books": [
        {
          "id": "bk101",
          "author": "Gambardella, Matthew",
          "title": "XML Developer's Guide",
          "genre": "Computer",
          "price": "44.95",
          "publicationDate": "2000-10-01",
          "desc": "An in-depth look at creating applications \n      with XML."
        },
        {
          "id": "bk102",
          "author": "Ralls, Kim",
          "title": "Midnight Rain",
          "genre": "Fantasy",
          "price": "5.95",
          "publicationDate": "2000-12-16",
          "desc": "A former architect battles corporate zombies, \n      an evil sorceress, and her own childhood to become queen \n      of the world."
        }
      ]
    })
