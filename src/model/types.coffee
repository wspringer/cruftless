Joi = require 'joi'
_ = require 'lodash'

module.exports = 

  string: 
    joi: Joi.string()
    from: _.identity
    to: _.identity

  integer: 
    joi: Joi.number().integer()
    from: (str) -> parseInt(str)
    to: (value) -> value.toString()

  float:
    joi: Joi.number()
    from: (str) -> parseFloat()
    to: (value) -> value.toString()    
