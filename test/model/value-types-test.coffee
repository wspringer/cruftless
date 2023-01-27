{ element, attr, text, parse } = require('../../src/cruftless')({
  types: {
    zeroOrOne: {
      type: "boolean",
      from: (str) => str == "1",
      to: (value) => if value then "1" else "0",
    },
  },
});

describe 'value types', ->
  it 'should allow you to use them in attributes', ->
    template = parse('<foo a="{{value|zeroOrOne}}"/>')
    expect(template.toXML({ value: true })).toEqual('<foo a="1"/>')
