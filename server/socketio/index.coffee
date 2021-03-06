'use strict'

socketioJwt = require('socketio-jwt')
config = require('../config/environment')
User = require('../api/user/user.model')
userControl = require('../api/user/user.controller')
resource = require('../api/resource/resource.controller')
gameControl = require('../api/game/game.controller')
events = require('events')

module.exports = (io) ->

  generateUUID = ->
    d = (new Date).getTime()
    uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
      r = (d + Math.random() * 16) % 16 | 0
      d = Math.floor(d / 16)
      (if c == 'x' then r else r & 0x3 | 0x8).toString 16
    )
    uuid

  class SocketDelegate
    constructor: ->
  
  SocketDelegate.prototype = Object.create(events.EventEmitter.prototype)

  class Client
    constructor: (@id, @profile = {}, options = {}) ->
      @userAgent = options.userAgent
      @address = options.address
      @socket = -> options.socket
      @regTm = new Date()

  class Room
    constructor: (@name, game) ->
      my = @
      @id = generateUUID()
      @clients = {}
      @regTm = new Date()
      if game
        @gameId = game.id
        @socketDelegate = new SocketDelegate()
        limitedSocket = 
          emit: (eventName, message) ->
            args = ['__message__']
            for each in arguments
              args.push each
            context = io.to(my.id)
            context.emit.apply context, args
            return
          emitTo: (receivers, eventName, message) ->
            args = ['__message__']
            for each in arguments
              args.push each
            receivers = args.shift()
            if Object::toString.call(someVar) isnt '[object Array]'
              receivers = [receivers]
            for receiver in receivers
              if my.clients[receiver.id]
                context = my.clients[receiver.id].socket()
                context.emit.apply context, args
            return
          on: (eventName, callback) ->
            my.socketDelegate.on.apply my.socketDelegate, arguments
            return
        @instance = game.factory(limitedSocket, {
          clients: ->
            my.clients
          eject: my.leave
        })

    join: (client) ->
      my = @
      if client.room and rooms.get(client.room)
        rooms.get(client.room).leave client
      client.room = @id
      client.socket().join @id
      client.callback = (eventName, nmessage) ->
        args = []
        for arg in arguments
          args.push arg
        args.splice(1, 0, client)
        my.socketDelegate.emit.apply my.socketDelegate, args
        return
      client.socket().on '__message__', client.callback
      @clients[client.id] = true
      io.to(@id).emit 'message', "#{client.profile.name} has entered the #{@name}."
      if @instance and typeof @instance.onenter is 'function'
        @instance.onenter client
      return

    leave: (client) ->
      if @instance and typeof @instance.onleave is 'function'
        @instance.onleave client
      io.to(@id).emit 'message', "#{client.profile.name} has left the #{@name}."
      client.socket().leave @id
      if client.callback
        client.socket().removeListener '__message__', client.callback
        delete client.callback
      delete @clients[client.id]
      client.room = null
      return

  clients =
    _dict: {}
    add: (socket, profile) ->
      if socket and socket.id
        handshake = socket.handshake or {}
        handshake.headers = handshake.headers or {}
        client = new Client(socket.id, profile, {
          userAgent: handshake.headers['user-agent']
          address: handshake.address
          socket: socket
        })
        @_dict[client.id] = client
        return client
      return

    get: (clientId) ->
      return @_dict[clientId] if clientId
      @_dict

    remove: (clientId) ->
      if @_dict[clientId] and @_dict[clientId].room
        room = rooms.get @_dict[clientId].room
        if room
          room.leave @_dict[clientId]
      delete @_dict[clientId]
      return

  rooms = 
    _dict: {}
    add: (name, game) ->
      room = new Room(name, game)
      @_dict[room.id] = room
      room

    get: (roomId) ->
      return @_dict[roomId] if roomId
      avail = {}
      for key, value of @_dict
        if Object.keys(value.clients).length > 0
          avail[key] = value
      avail

  lobby = rooms.add 'lobby'

  io.use socketioJwt.authorize(
    secret: config.secrets.session
    handshake: true
  )

  io.on 'connection', (socket) ->

    User.findById socket.decoded_token._id, (err, user) ->
      return if err

      client = clients.add socket, user
      lobby.join client
      socket.emit 'stat.me', client
      io.emit 'stat.clients', clients.get()
      io.emit 'stat.rooms', rooms.get()

      # userControl.setListener user, (user) ->
      #   # console.log '>>>>>'
      #   allClients = clients.get()
      #   # console.log '>>> ' + user._id
      #   for clientId, each of allClients
      #     # console.log each.profile
      #     if each.profile._id.toString() is user._id.toString()
      #       # console.log '>>> '
      #       each.profile = user
      #     # console.log client
      #   # client.profile = user
      #   socket.emit 'stat.me', client
      #   io.emit 'stat.clients', clients.get()      

      socket.on 'message', (message) ->
        client = clients.get socket.id
        if client.room
          io.to(client.room).emit 'message', "#{client.profile.name} : #{message}"
        return

      socket.on 'room.create', (data) ->
        client = clients.get socket.id
        gameControl.get data.gameId, (err, game) ->
          if game and game.factory
            room = rooms.add data.name, game
          else
            room = rooms.add data.name
          room.join client
          socket.emit 'stat.me', client
          io.emit 'stat.clients', clients.get()
          io.emit 'stat.rooms', rooms.get()
          return
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
          if room.name isnt 'lobby'
            lobby.join client
          socket.emit 'stat.me', client
          io.emit 'stat.clients', clients.get()
          io.emit 'stat.rooms', rooms.get()
        return

      socket.on 'disconnect', ->
        clients.remove socket.id
        io.emit 'stat.clients', clients.get()
        io.emit 'stat.rooms', rooms.get()
        return

      return

    return