_ = require 'lodash'

module.exports =

  string:
    desc: type: 'string'
    from: _.identity
    to: _.identity
    relaxng: ({element, attr}) -> element('data').attrs(attr('type').value('string'))

  integer:
    desc: type: 'integer'
    from: (str) -> parseInt(str)
    to: (value) -> value.toString()
    relaxng: ({element, attr}) -> element('data').attrs(attr('type').value('integer'))

  float:
    desc : type: 'float'
    from: (str) -> parseFloat()
    to: (value) -> value.toString()
    relaxng: ({element, attr}) -> element('data').attrs(attr('type').value('float'))

  boolean:
    desc: type: 'boolean'
    from: (str) -> str is 'true'
    to: (value) ->
      value.toString()
    relaxng: ({element, attr}) -> element('data').attrs(attr('type').value('boolean'))
