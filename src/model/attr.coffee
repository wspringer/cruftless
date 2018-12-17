module.exports = (name) ->
  self = @
  meta = 
    name: name
    required: false

  exposed = 

    required: ->
      meta.required = true
      exposed

    ns: (ns) ->
      meta.ns = ns
      exposed            

    bind: (expr) ->
      meta.bind = expr  
      exposed

    value: (value) ->
      meta.value = value
      exposed      

    add: (obj, elem) ->
      if meta.ns?
        elem.setAttributeNS(meta.ns, meta.name, meta.value or meta.name)
      else 
        elem.setAttribute(meta.name, meta.value or meta.name)


  exposed




