accessor = require '../../src/expr/accessor'

describe 'the accessor', ->

  describe 'its get method', ->

    it 'should allow you to get object values ', ->
      expect(accessor.of('a.b').get({ a: b: 4})).toEqual(4)

    it 'should allow you to get array values', ->
      expect(accessor.of('a[0][1]').get({
        a: [
          [1, 2],
          [3, 4]
        ]
      })).toEqual(2)   

    it 'should allow you to access array values directly', ->
      expect(accessor.of('[1]').get(['a', 'b'])).toEqual('b')
  

  describe 'its set method', ->
    
    it 'should allow you to set object values', ->
      obj = { a: 2 }
      accessor.of('a').set(obj, 3)
      expect(obj).toEqual({ a: 3})

    it 'should autocreate new objects', ->
      obj = {} 
      accessor.of('a.b').set(obj, 3)
      expect(obj).toEqual({ a: b: 3 })  

    it 'should leave existing state intact', ->
      obj = { a: c: 2 }      
      accessor.of('a.b').set(obj, 3)
      expect(obj).toEqual({ a: {
        c: 2,
        b: 3
      }})

    it 'should leave existing state intact with deeply nested objects', ->
      obj = { a: b: c: 2 }      
      accessor.of('a.d.e').set(obj, 3)
      expect(obj).toEqual({
        a: {
          b: {
            c: 2
          },
          d: {
            e: 3
          }
        }
      })

    it 'should allow you to set nested array elements', ->
      arr = []
      accessor.of('[2]').set(arr, 3)
      expect(arr).toEqual([undefined, undefined, 3])  

    it 'should automatically create nested array elements', ->
      arr = []
      accessor.of('[0][0][0]').set(arr, 3)
      expect(arr).toEqual([[[3]]])

    it 'should leave existing data intact when setting nested array elements', ->
      arr = [[1], [3, 4]]
      accessor.of('[0][1]').set(arr, 2)
      expect(arr).toEqual([[1, 2], [3, 4]])      

    it 'should handle order correctly and not be affected by the implementation of a descriptor method', ->
      obj = {}
      accessor.of('persons[0].name').set(obj, 'Joe')      
      expect(obj).toEqual({ persons: [ { name: 'Joe' } ] })


  describe 'its descriptor method', ->
  
    it 'should handle simple object references', ->
      expect(accessor.of('a.b.c').descriptor()).toEqual({"keys": {"a": {"keys": {"b": {"keys": {"c": {"type": "any"}}, "type": "object"}}, "type": "object"}}, "type": "object"})

    it 'should handle simple array references', ->
      expect(accessor.of('a[0]').descriptor()).toEqual( {"keys": {"a": {"element": {"type": "any"}, "type": "array"}}, "type": "object"})

    it 'should hanle mixed references', ->
      expect(accessor.of('a[0].b[0][1]').descriptor()).toEqual(
        {"keys": {"a": {"element": {"keys": {"b": {"element": {"element": {"type": "any"}, "type": "array"}, "type": "array"}}, "type": "object"}, "type": "array"}}, "type": "object"}
      )      

  describe 'its describe method', ->
    
    it 'should merge data with the target getting passed in', ->
      merged = accessor.of('a.b').describe({
        type: 'object'
        keys: {
          d: { type: 'integer' }
          e: { type: 'boolean' }
        }
      })
      expect(merged).toEqual({"keys": {"a": {"keys": {"b": {"type": "any"}}, "type": "object"}, "d": {"type": "integer"}, "e": {"type": "boolean"}}, "type": "object"})
