cruftless = require('../../src/cruftless')
{ element, attr, text, parse } = cruftless()

describe 'processing instructions', ->

  it 'should allow you to use processing instructions to bind data', ->
    template = parse('<persons><person><?bind persons|array?>{{name}}</person></persons>')
    data = {
      persons: [
        { name: 'Wilfred' }, { name: 'Levi' }
      ]
    }
    expect(template.toXML(data)).toEqual('<persons><person>Wilfred</person><person>Levi</person></persons>')


