_ = require 'lodash'

module.exports = (opts = {}) ->

  opts = _.cloneDeep(opts)

  opts.types = _.merge({}, require('./model/types'), opts.types or {})

  element = require('./model/element')(opts)
  attr = require('./model/attr')(opts)
  text = require('./model/text')(opts)
  parse = require('./model/builder')({ element, attr, text })

  { element, attr, text, parse }
