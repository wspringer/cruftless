{ parse, attr, element, text } = require('../../src/cruftless')()
{ xsiNS } = require '../../src/ns'


describe 'xsi:type support', ->

  # To make sure we continue to behave as we did (although this may be false)
  it 'should continue to consider a value bound to a literal to be set', ->
    a = attr('a').value('3')
    expect(a.isSet({})).toBe(true)

  it 'should consider a xsi:type attribute corresponding with a kind property to be set', ->
    a = attr('type').ns(xsiNS).value('B')
    expect(a.isSet({ kind: 'B' })).toBe(true)

  it 'should preserve xsi:type attributes', ->
    template = parse("<foo xmlns:xsi='#{xsiNS}'><bar xsi:type='B'/></foo>")
    expect(template.toXML()).toEqual('<foo xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><bar xsi:type=\"B\"/></foo>')

  it 'should respect the kind property', ->
    template = parse("<foo xmlns:xsi='#{xsiNS}'><bar xsi:type='B'/></foo>")
    expect(template.toXML(kind: 'B')).toEqual('<foo xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><bar xsi:type=\"B\"/></foo>')
    expect(template.toXML(kind: 'C')).toEqual('<foo xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"/>')

  it 'should extract data correctly', ->
    template = parse("<foo xmlns:xsi='#{xsiNS}'><bar xsi:type='B'>{{b}}</bar></foo>")
    expect(template.fromXML('<foo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><bar xsi:type="B">3</bar></foo>')).toEqual b: '3', kind: 'B'

  it 'should not extract data correctly if the kind doesn\'t match', ->
    template = parse("<foo xmlns:xsi='#{xsiNS}'><bar xsi:type='B'>{{b}}</bar></foo>")
    expect(template.fromXML('<foo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><bar xsi:type="C">3</bar></foo>')).toEqual {}

  it 'should not extract data correctly if the kind doesn\'t match', ->
    template = parse("""
<foo xmlns:xsi='#{xsiNS}'>
<bar xsi:type='B'>{{b}}</bar>
<bar xsi:type='C'>{{c}}</bar>
</foo>""".trim())
    expect(template.fromXML('<foo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><bar xsi:type="C">3</bar></foo>')).toEqual c: '3', kind: 'C'

  it 'should extract repeating rows', ->
    template = parse("""
  <foo xmlns:xsi='#{xsiNS}'>
  <bar c-bind="bs|array" xsi:type='B'>{{b}}</bar>
  <bar c-bind="cs|array" xsi:type='C'>{{c}}</bar>
  </foo>""".trim())
    expect(template.fromXML('<foo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><bar xsi:type="C">3</bar><bar xsi:type="C">4</bar></foo>')).toEqual cs: [{c: '3', kind: 'C'}, {c: '4', kind: 'C'}]

  it 'should allow you to mix values', ->
    template = parse("""
  <foo xmlns:xsi='#{xsiNS}'>
  <bar c-bind="as|array" xsi:type='B'>{{b}}</bar>
  <bar c-bind="as|array" xsi:type='C'>{{c}}</bar>
  </foo>""".trim())
    expect(template.fromXML('<foo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><bar xsi:type="B">3</bar><bar xsi:type="C">4</bar></foo>')).toEqual as: [{b: '3', kind: 'B'}, {c: '4', kind: 'C'}]

  it 'should allow you to mix values, with order reversed', ->
    template = parse("""
  <foo xmlns:xsi='#{xsiNS}'>
  <bar c-bind="as|array" xsi:type='B'>{{b}}</bar>
  <bar c-bind="as|array" xsi:type='C'>{{c}}</bar>
  </foo>""".trim())
    # This is unexpected. I actually didn't expect this to work.
    expect(template.fromXML('<foo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><bar xsi:type="C">4</bar><bar xsi:type="B">3</bar></foo>')).toEqual as: [{c: '4', kind: 'C'},{b: '3', kind: 'B'}]