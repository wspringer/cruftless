{ element, attr, text, parse } = require('../../src/cruftless')()

describe 'default values', ->

  it 'should allow you to set default values in value bindings in text nodes', ->
    template = parse('<person>{{name|default:charles}}</person>')
    expect(template.toXML({})).toEqual('<person>charles</person>')
    expect(template.toXML()).toEqual('<person>charles</person>')
    expect(template.toXML({name: 'Barney'})).toEqual('<person>Barney</person>')

  it 'should allow you to set default values in value bindings in attributes', ->
    template = parse('<person name="{{name|default:charles}}"/>')
    expect(template.toXML({})).toEqual('<person name="charles"/>')
    expect(template.toXML()).toEqual('<person name="charles"/>')
    expect(template.toXML({name: 'Barney'})).toEqual('<person name="Barney"/>')

  it 'should allow you to set default values in value bindings in comments', ->
    template = parse('<person><!--{{name|default:charles}}--></person>')
    expect(template.toXML({})).toEqual('<person><!--charles--></person>')
    expect(template.toXML()).toEqual('<person><!--charles--></person>')
    expect(template.toXML({name: 'Barney'})).toEqual('<person><!--Barney--></person>')
