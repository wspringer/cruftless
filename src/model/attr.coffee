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

    add: (obj, elem) ->
      if meta.ns?
        elem.setAttributeNS(meta.ns, meta.name, 'watte')
      else 
        elem.setAttribute(meta.name, 'watte')


  exposed




