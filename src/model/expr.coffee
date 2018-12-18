
_ = require 'lodash'

raw = /([\.a-zA-Z0-9]+)(?:\|([\.a-zA-Z0-9]+))?(?:\|([\.a-zA-Z0-9]+))?(?:\|([\.a-zA-Z0-9]+))?(?:\|([\.a-zA-Z0-9]+))?/
curly = /\{\{([\.a-zA-Z0-9]+)(?:\|([\.a-zA-Z0-9]+))?(?:\|([\.a-zA-Z0-9]+))?(?:\|([\.a-zA-Z0-9]+))?(?:\|([\.a-zA-Z0-9]+))?\}\}/


parser = (regex) -> 
  
  parse = (str) ->
    match = str.match(regex)
    if match? then _.reject(_.tail(match), _.isUndefined)
  
  (str) ->
  
    parsed = parse(str)

    parsed: parsed

    apply: (context) ->
      if not(parsed?) or parsed.length is 0 then context.value(str)
      else 
        _.reduce(_.tail(parsed), (acc, term) ->
          if acc[term] then acc[term]() else acc
        , context.bind(_.head(parsed)))          

module.exports = 
  raw: parser(raw)
  curly: parser(curly)




