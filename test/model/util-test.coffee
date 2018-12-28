{ parseExpr } = require '../../src/model/util'

describe 'util', ->

  describe 'its parseExpr', ->

    describe 'its describe method', ->

      it 'should correctly handle simple expressions', ->
        desc = {}
        parsed = parseExpr('a.b.c')
        parsed.describe(desc, { type: 'string' })
        expect(desc).toEqual({"a": {"keys": {"b": {"keys": {"c": {"type": "string"}}, "type": "object"}}, "type": "object"}})

      it 'should correctly merge multiple references, outer first', ->
        desc = {}
        parsed = parseExpr('a.b.c')
        parsed.describe(desc, { type: 'string' })
        parseExpr('a.b.d').describe(desc, { type: 'string'})
        parseExpr('a.b').describe(desc, { type: 'object' })
        expect(desc).toEqual({"a": {"keys": {"b": {"keys": {"c": {"type": "string"}, "d": {"type": "string"}}, "type": "object"}}, "type": "object"}})

      it 'should correctly merge multiple references, outer last', ->
        desc = {}
        parsed = parseExpr('a.b.c')
        parsed.describe(desc, { type: 'string' })
        parseExpr('a.b').describe(desc, { type: 'object' })
        parseExpr('a.b.d').describe(desc, { type: 'string'})
        expect(desc).toEqual({"a": {"keys": {"b": {"keys": {"c": {"type": "string"}, "d": {"type": "string"}}, "type": "object"}}, "type": "object"}})
        

