_ = require 'lodash'

module.exports = (opts = {}) ->

  types = _.merge({}, require('./model/types'), opts.types or {})

  element = require('./model/element')(types)
  attr = require('./model/attr')(types)
  text = require('./model/text')(types)
  parse = require('./model/builder')({ element, attr, text })

  { element, attr, text, parse }
