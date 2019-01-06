module.exports = (expr) ->

  buffer = ''
  length = expr.length
  pos = 0
  results = []

  start = 
    final: false
    handle: (c) ->
      switch 
        when c is '[' then indexHead
        when /[_a-zA-Z]/.test(c) 
          buffer += c
          key

  indexHead = 
    final: false
    handle: (c) ->
      switch 
        when /[0-9]/.test(c) 
          buffer += c
          indexTail

  key =
    final: true
    done: -> 
      results.push { type: 'property', key: buffer }
    handle: (c) ->
      switch
        when c is '.'
          results.push { type: 'property', key: buffer }
          buffer = ''
          preKey
        when /[_a-zA-Z0-9]/.test(c) 
          buffer += c
          key
        when c is '['
          results.push { type: 'property', key: buffer }  
          buffer = ''
          indexHead

  indexTail = 
    final: false
    handle: (c) ->
      switch
        when c is ']'
          results.push { type: 'element', index: buffer }
          buffer = ''
          postIndex
        when /[0-9]/.test(c)
          buffer += c
          indexTail

  preKey = 
    final: false
    handle: (c) ->
      switch
        when /[_a-zA-Z]/.test(c)
          buffer += c
          key

  postIndex =
    final: true
    done: -> 
    handle: (c) ->
      switch
        when c is '.'
          preKey
        when c is '['
          indexHead

  state = start

  while pos < length    
    c = expr.charAt(pos)
    next = state.handle(c)
    throw new Error("Unexpected character '#{c}' at position #{pos}") unless next? 
    pos += 1
    state = next

  if state.final
    state.done()
    results
  else throw new Error('Expecting more input')
      
