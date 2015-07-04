'use strict'

express = require('express')
path = require('path')
favicon = require('serve-favicon')
morgan = require('morgan')
compression = require('compression')
passport = require('passport')
errorHandler = require('errorhandler')

process.env.NODE_ENV = process.env.NODE_ENV or 'development'

config =
  root: path.normalize(__dirname + '/..')
  env: process.env.NODE_ENV
  port: process.env.PORT or 8000
  ip: process.env.IP or undefined

app = express()
app.use compression()

app.use passport.initialize()
app.use passport.session()

if 'production' == config.env
  app.use morgan('dev')
  app.use favicon(path.join(config.root, 'public', 'favicon.ico'))
  app.use express['static'](path.join(config.root, 'public'))

if 'development' == config.env or 'test' == config.env
  app.use require('connect-livereload')()
  # app.use morgan('dev')
  app.use favicon(path.join(config.root, 'public', 'favicon.ico'))
  app.use express['static'](path.join(config.root, '.tmp'))
  app.use express['static'](path.join(config.root, 'public'))
  app.use errorHandler()

server = require('http').createServer(app)
server.listen config.port, config.ip, ->
  #console.log  'Express server listening on %d, in %s mode', config.port, config.env
  return

require('./routes') app

io = require('socket.io')(server)
# #   serveClient: ((if config.env is 'production' then false else true))
# #   path: '/socket.io-client'
# # )

# io = require('socket.io')(http)
# app.get '/', (req, res) ->
#   res.sendfile 'index.html'
#   return

shallowCopy = (obj, depth = 0) ->
  ret = {}

  for key of obj
    # #console.log  key
    if obj.hasOwnProperty(key)
      if typeof obj[key] isnt 'object'
        ret[key] = obj[key]
      else if typeof obj[key] is 'object' and depth < 4
        ret[key] = shallowCopy(obj[key], depth + 1)
  ret





clients =
  _dict: {}
  add: (socket) ->
    if socket and socket.id
      handshake = socket.handshake or {}
      handshake.headers = handshake.headers or {}
      client = new Client(socket.id, {
        clientAgent: handshake.headers['user-agent']
        address: handshake.address
        socket: socket
      })
      @_dict[client.id] = client
      return client
    return

  get: (clientId) ->
    return @_dict[clientId] if clientId
    @_dict

  set: (clientId, data) ->

  remove: (clientId) ->
    if @_dict[clientId] and @_dict[clientId].room
      room = rooms.get @_dict[clientId].room
      if room
        room.leave @_dict[clientId]
    delete @_dict[clientId]
    return

generateUUID = ->
  d = (new Date).getTime()
  uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
    r = (d + Math.random() * 16) % 16 | 0
    d = Math.floor(d / 16)
    (if c == 'x' then r else r & 0x3 | 0x8).toString 16
  )
  uuid

class Client
  constructor: (@id, options = {}) ->
    @clientAgent = options.clientAgent
    @address = options.address
    @socket = -> options.socket
    @regTm = new Date()

class Room
  constructor: (@name) ->
    @id = generateUUID()
    @clients = {}
    # @clientAgent = options.clientAgent
    # @address = options.address
    # # @socket = options.socket
    @regTm = new Date()

  join: (client) ->
    if client.room and rooms.get(client.room)
      rooms.get(client.room).leave client
    client.room = @id
    client.socket().join @id
    @clients[client.id] = true
    io.to(@id).emit 'message', 'new guest has joined'
    return

  leave: (client) ->    
    io.to(@id).emit 'message', 'guest has left'    
    console.log client.socket()
    client.socket().leave @id
    delete @clients[client.id]
    client.room = null
    return

rooms = 
  _dict: {}
  add: (name) ->
    room = new Room(name)
    @_dict[room.id] = room
    room

  get: (roomId) ->
    return @_dict[roomId] if roomId
    avail = {}
    for key, value of @_dict
      if Object.keys(value.clients).length > 0
        avail[key] = value
    avail

  set: (roomId, data) ->

  remove: (roomId) ->
    
    # delete @_dict[socket.id]
    return




io.on 'connection', (socket) ->

  client = clients.add socket
  socket.emit 'stat.me', client
  io.emit 'stat.clients', clients.get()
  io.emit 'stat.rooms', rooms.get()

  socket.on 'message', (message) ->
    client = clients.get socket.id
    if client.room
      io.to(client.room).emit 'message', 'room message : ' + message
    return

  socket.on 'room.create', (data) ->
    client = clients.get socket.id
    room = rooms.add data.name
    room.join client
    socket.emit 'stat.me', client
    io.emit 'stat.clients', clients.get()
    io.emit 'stat.rooms', rooms.get()
    return

  socket.on 'room.join', (roomId) ->
    client = clients.get socket.id
    room = rooms.get roomId
    if room
      room.join client
      socket.emit 'stat.me', client
      io.emit 'stat.clients', clients.get()
      io.emit 'stat.rooms', rooms.get()
    return

  socket.on 'room.leave', (roomId) ->
    client = clients.get socket.id
    room = rooms.get roomId
    if room
      room.leave client
      socket.emit 'stat.me', client
      io.emit 'stat.clients', clients.get()
      io.emit 'stat.rooms', rooms.get()
    return

  socket.on 'disconnect', ->
    clients.remove socket.id
    io.emit 'stat.clients', clients.get()
    io.emit 'stat.rooms', rooms.get()
    return

  # tmp = shallowCopy(io)
  # socket.emit 'socketInfo', tmp
  return



exports = module.exports = app
