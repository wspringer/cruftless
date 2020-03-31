_ = require 'lodash'

module.exports =

  string:
    desc: type: 'string'
    from: _.identity
    to: _.identity

  integer:
    desc: type: 'integer'
    from: (str) -> parseInt(str)
    to: (value) -> value.toString()

  float:
    desc : type: 'float'
    from: (str) -> parseFloat()
    to: (value) -> value.toString()

  boolean:
    desc: type: 'boolean'
    from: (str) -> str is 'true'
    to: (value) ->
      value.toString()
