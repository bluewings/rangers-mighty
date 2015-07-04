'use strict'

process.env.NODE_ENV = process.env.NODE_ENV or 'development'

express = require('express')
mongoose = require('mongoose')
config = require('./config/environment')

mongoose.connect config.mongo.uri, config.mongo.options

# require './config/seed' if config.seedDB

app = express()

server = require('http').createServer(app)
socketio = require('socket.io')(server,
  serveClient: ((if config.env is 'production' then false else true))
  path: '/socket.io'
)

require('./config/express') app
require('./socketio') socketio
require('./routes') app

server.listen config.port, config.ip, ->
  console.log 'Express server listening on %d, in %s mode', config.port, app.get('env')
  return

exports = module.exports = app
