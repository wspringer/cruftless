format = require('xml-formatter')
cruftless = require('./src/cruftless')

compact = (str) ->
  # str
  format(str, { collapseContent: true, indentation: '  ' })

###
Wraps cruftless to add some formatting not included by default.
###
module.exports = (opts) ->
  cruftless({ opts..., format: compact})
