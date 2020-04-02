_ = require 'lodash'

module.exports =

  string:
    desc: type: 'string'
    from: _.identity
    to: _.identity
    xsDataType: 'string'

  integer:
    desc: type: 'integer'
    from: (str) -> parseInt(str)
    to: (value) -> value.toString()
    xsDataType: 'integer'

  float:
    desc : type: 'float'
    from: (str) -> parseFloat()
    to: (value) -> value.toString()
    xsDataType: 'float'

  boolean:
    desc: type: 'boolean'
    from: (str) -> str is 'true'
    to: (value) ->
      value.toString()
    xsDataType: 'boolean'
