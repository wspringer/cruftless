module.exports = ->
  self = @
  meta = {}

  bind: (expr) ->
    meta.bind = expr
    self

  { bind }    

