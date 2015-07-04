'use strict'

module.exports = (app) ->

  # Insert routes below
  # app.use '/api/users', require('./api/user')
  # app.use '/api/slides', require('./api/slide')
  app.use '/auth', require('./auth')

  return
