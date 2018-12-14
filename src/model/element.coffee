element = (name) ->
  self = @
  meta = 
    name: name
    attrs: []
    content: []
  
  attrs = (attr...) -> 
    meta.attrs.push(attr...) 
    self

  content = (elem...) -> 
    meta.content.push(elem...)
    self

  ns = (ns) -> 
    meta.ns = ns
    self    

  { attrs, content, ns }    


attr = (name) ->
  meta = 
    name: name
    required: false

  required: ->
    meta.required = true
    self

  bind: (expr) ->
    meta.bind = expr  

  { required, bind }    


text = ->
  meta = {}
  
  bind: (expr) ->
    meta.bind = expr

  { bind }    

module.exports = {
  element
  attr
  text
}







