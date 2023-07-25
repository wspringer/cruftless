_ = require 'lodash'

module.exports = (opts = {}) ->

  opts = _.cloneDeep(opts)

  opts.types = _.merge({}, require('./model/types'), opts.types or {})

  opts.kindProperty = opts.kindProperty or 'kind'

  opts.prefixes = opts.prefixes or {}

  element = require('./model/element')(opts)

  attr = require('./model/attr')(opts)

  text = require('./model/text')(opts)

  capture = require('./model/capture')(opts)

  comment = require('./model/comment')(opts)

  parse = require('./model/builder')({ element, attr, text, comment, capture })

  relaxngAny =
    element('zeroOrMore')
      .ns('http://relaxng.org/ns/structure/1.0')
      .content(
        element('choice').content(
          element('element').content(
            element('anyName'),
            element('ref').attrs(attr('name').value('any'))
          ),
          element('attribute').content(
            element('anyName')
          ),
          element('text')
        )
      )


  ###
   Produces a RelaxNG schema for the given template. Refs will be resolved using
   the object passed in. If there is a reference to something not defined in the
   schema, then we will attempt to resolve it using the refs object. If it
   exist, we will add a definition of that name and inline the corresponding
   snippet.
   ###
  relaxng = (template, refs = {}) ->
    refElementsFound = []
    trackingElement = (name) ->
      created = element(name)
      if name is 'ref'
        refElementsFound.push(created)
      created
    schema = template.relaxng({ element: trackingElement, attr, text })
    refsFound = refElementsFound.map (ref) -> ref.getAttribute('name')?.getValue()
    definitions = _.uniq(refsFound).map (name) ->
      if refs[name]?
        element('define')
          .attrs(attr('name').value(name))
          .content(
            refs[name]
          )
      else
        element('define')
          .attrs(attr('name').value(name))
          .content(relaxngAny)
    element('grammar')
    .ns('http://relaxng.org/ns/structure/1.0')
    .attrs(
      attr('datatypeLibrary').value('http://www.w3.org/2001/XMLSchema-datatypes')
    )
    .content(
      element('start').content(
        schema
      ),
      definitions...
    ).toXML()

  { element, attr, text, parse, relaxng, capture }
