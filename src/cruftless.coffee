_ = require 'lodash'

module.exports = (opts = {}) ->

  opts = _.cloneDeep(opts)

  opts.types = _.merge({}, require('./model/types'), opts.types or {})

  element = require('./model/element')(opts)
  attr = require('./model/attr')(opts)
  text = require('./model/text')(opts)
  parse = require('./model/builder')({ element, attr, text })
  relaxng = (template) ->
    element('grammar')
    .ns('http://relaxng.org/ns/structure/1.0')
    .attrs(
      attr('datatypeLibrary').value('http://www.w3.org/2001/XMLSchema-datatypes')
    )
    .content(
      element('start').content(
        template.relaxng({ element, attr, text })
      )
    ).toXML()

  { element, attr, text, parse, relaxng }
