'use strict'

_ = require('lodash')
async = require('async')
socketioJwt = require('socketio-jwt')
config = require('../config/environment')
User = require('../api/user/user.model')
game = require('../../game')

timer = {}
clients = []
rooms = []

uid = -> (parseInt(Math.random() * 900000000 + 100000000, 10)).toString(36).substr 0, 6

room =
  _io: null
  _rooms: {
    welcome: {
      controller: 'welcomeCtrl'
    }
  }
  _clients: {}
  WELCOME: 'welcome'
  updateList: ->
    that = this
    clearTimeout that._timerUpdateList
    that._timerUpdateList = setTimeout ->
      if that._io
        rooms = []
        clientIds = Object.keys(that._io.sockets.connected)
        Object.keys(that._io.sockets.adapter.rooms).forEach (roomId) ->
          if clientIds.indexOf(roomId) == -1
            _clients = Object.keys(that._io.sockets.adapter.rooms[roomId])
            if _clients.length > 0
              info = that._rooms[roomId] or {}
              rooms.push
                roomId: roomId
                type: info.type
                name: info.name or ''
                option: info.option or {}
                createdTm: info.createdTm
                clientIds: _clients
                clientCount: _clients.length

        emitEvent null, that._io.sockets, 'room.list',
          rooms: rooms
    , 10

  create: (socket, data) ->
    that = this
    roomId = uid()
    info = game.find(data.type)
    this._rooms[roomId] = {
      name: (data and data.name) or ''
      type: (data and data.type) or this.WELCOME
      option: (data and data.option) or {}
      createdTm: (new Date()).toISOString()
    }
    if info and info.factory
      sockets = null
      ((roomId) ->
        that._rooms[roomId]._listener = {}
        sockets = {
          on: (eventNamme, listener) ->
            that._rooms[roomId]._listener[eventNamme] = listener

          emit: (eventName, data, playerDict) ->
            # emit global
            response =
              type: eventName
              data: data

            if playerDict and that._io.sockets.adapter.rooms[roomId]

              _socketIds = Object.keys(that._io.sockets.adapter.rooms[roomId])
              for socketId in _socketIds
                # emit secrets
                if playerDict and playerDict[socketId]
                  response.secret = playerDict[socketId].secret
                # emitChannelMessage null, that._io.to(socketId), 'room.message.server', response
            else

              # emitChannelMessage null, that._io.sockets.in(roomId), eventName, response

              that._io.sockets.in(roomId).emit "game.channel.#{roomId}", {
                type: eventName
                # from: socketFrom.id
                eventTm: (new Date()).toISOString()
                data: data
              }
              # emitChannelMessage null, that._io.sockets.in(roomId), eventName, response
        }
      )(roomId)
      this._rooms[roomId].instance = info.factory(sockets)


    this.enter(socket, roomId)

  enter: (socket, roomId, callback) ->
    that = this
    funcs = []
    # leave other rooms
    for otherRoomId in socket.rooms
      if socket.id isnt otherRoomId
        funcs.push ((socket, otherRoomId) ->
          (callback) ->
            that.leave socket, otherRoomId, callback
        )(socket, otherRoomId)

    async.series funcs, (err, results) ->
      unless err
        # enter room
        socket.join roomId, (err) ->
          if err
            callback err if callback
          else
            unless that._clients[socket.id]
              that._clients[socket.id] = rooms: {}
            that._clients[socket.id].rooms[roomId] = true
            target = that._rooms[roomId] or {}
            # notify to client
            emitEvent socket, socket, 'room.enter',
              roomId: roomId
              type: target.type or that.WELCOME
            # notify to other clients in room
            emitEvent socket, that._io.sockets.in(roomId), 'room.join',
              message: "#{socket.id} has joined the room."
              clients: clients
            # notify to other clients in room for chat message
            if roomId is that.WELCOME
              emitMessage null, that._io.sockets.in(roomId), "[socketId:#{socket.id}] has entered the lobby."
            else
              emitMessage null, that._io.sockets.in(roomId), "[socketId:#{socket.id}] has joined the room."



            # notify to target room instance
            if target.instance and target.instance.onenter
              target.instance.onenter socket
              # target.instance.onenter socket.id, Object.keys(that._io.sockets.adapter.rooms[roomId])
            callback null if callback
            that.updateList()

  leave: (socket, roomId, callback) ->
    that = this
    socket.leave roomId, (err) ->
      if err
        callback err if callback
      else
        unless that._clients[socket.id]
          that._clients[socket.id] = rooms: {}
        delete that._clients[socket.id].rooms[roomId]
        target = that._rooms[roomId] or {}
        # notify to other clients in room
        if that._io
          emitEvent socket, that._io.sockets.in(roomId), 'room.leave',
            message: "#{socket.id} has left the room."
            clients: clients
          if roomId is that.WELCOME
            emitMessage null, that._io.sockets.in(roomId), "[socketId:#{socket.id}] has left the lobby."
          else
            emitMessage null, that._io.sockets.in(roomId), "[socketId:#{socket.id}] has left the room."


        # notify to target room instance

        if target.instance and target.instance.onexit

          target.instance.onexit socket
          # target.instance.onexit socket.id, Object.keys(that._io.sockets.adapter.rooms[roomId] or {})
        callback null if callback
        that.updateList()

  leaveAll: (socket, callback) ->
    that = this
    funcs = []
    if that._clients[socket.id]
      Object.keys(that._clients[socket.id].rooms).forEach (roomId) ->
        funcs.push ((socket, roomId) ->
          (callback) ->
            that.leave socket, roomId, callback
        )(socket, roomId)

    async.series funcs, (err, results) ->
      callback if err then err else null if callback

registerIO = (io) ->

  room._io = io

registerSocket = (socket, io)  ->

  socket.on 'room.create', (data) ->
    room.create socket, data

  socket.on 'room.enter', (data) ->
    room.enter socket, data.roomId

  socket.on 'room.leave', (data) ->
    room.enter socket, room.WELCOME


  socket.on 'game.channel', (data) ->
    # 해당 채널이 존재하고 참여자이면서 해당 이벤트 리스터가 있으면
    if data.roomId and room._rooms[data.roomId] and room._rooms[data.roomId]._listener and io.sockets.adapter.rooms[data.roomId] and io.sockets.adapter.rooms[data.roomId][socket.id] and room._rooms[data.roomId]._listener[data.method]
      context = _reqId: data._reqId


      if data._hasCallback
        callback = (params) ->
          params = []
          for arg in arguments
            params.push arg
          socket.emit "game.channel.callback.#{data.roomId}", {
            _reqId: data._reqId
            type: data.method
            eventTm: (new Date()).toISOString()
            params: params
          }
      else
        callback = ->
      data.params.unshift socket
      data.params.push callback
      room._rooms[data.roomId]._listener[data.method].apply context, data.params


  socket.on 'message', (message) ->
    rooms = getRooms(socket)
    if rooms.length is 1
      emitMessage socket, io.sockets.in(rooms[0]), message
    else
      console.log 'report error'

  room.enter socket, room.WELCOME

getRooms = (socket) ->
  rooms = []
  for roomId in socket.rooms
    if roomId isnt socket.id
      rooms.push roomId
  return if rooms.length is 0 then false else rooms

emitMessage = (socketFrom, socketsTo, message, callback) ->
  socketsTo.emit 'message', {
    from: if socketFrom and socketFrom.id then socketFrom.id else 'system'
    messageTm: (new Date()).toISOString()
    data: message
  }
  return

emitChannelMessage = (socketFrom, socketsTo, eventType, data, callback) ->
  socketsTo.emit 'game.channel', {
    type: eventType
    # from: socketFrom.id
    eventTm: (new Date()).toISOString()
    data: data
  }
  return

emitEvent = (socketFrom, socketsTo, eventType, data, callback) ->
  socketsTo.emit 'event', {
    type: eventType
    # from: socketFrom.id
    eventTm: (new Date()).toISOString()
    data: data
  }
  return

exceptDisconnectedClients = (clients, io) ->

  newClients = []
  for client in clients
    if io.sockets.connected[client.socketId]
      newClients.push client
  newClients

onConnect = (socket, io, client) ->

  index = _.findIndex clients, { socketId: socket.id }
  if index is -1
    clients.push client
  clients = exceptDisconnectedClients clients, io

  emitEvent socket, io.sockets, 'client.connect',
    message: "#{client.name} has joined."
    clients: clients

  registerSocket socket, io
  return

onDisconnect = (socket, io) ->

  room.leaveAll socket, (err, data) ->
    index = _.findIndex clients, { socketId: socket.id }
    if index isnt -1
      client = clients[index]
      clients.splice index, 1
    else
      client = name: 'unknown'
    clients = exceptDisconnectedClients clients, io

    emitEvent socket, io.sockets, 'client.disconnect',
      message: "#{client.name} has left."
      clients: clients
    return

  return

module.exports = (io) ->

  registerIO io

  io.use socketioJwt.authorize(
    secret: config.secrets.session
    handshake: true
  )

  io.on 'connection', (socket) ->

    User.findById socket.decoded_token._id, (err, user) ->
      if err
        timer.disconnect = setTimeout ->
          socket.disconnect()
        , 1000
        emitEvent socket, socket, 'client.connectFail',
          message: "#{client.name} has joined."

        socket.emit 'event', {
          type: 'client.connect'
          data:
            message: 'user not found.',
            clients: clients
        }, ->
          clearTimeout timer.disconnect
          socket.disconnect()
      else
        if user.naver
          profile = image: user.naver.profile_image
        else
          profile = {}

        client =
          socketId: socket.id
          _id: user.id
          name: user.name
          email: user.email
          provider: user.provider
          role: user.role
          profile: profile
          connectedTm: (new Date()).toISOString()

        socket.on 'disconnect', ->
          onDisconnect socket, io
          console.info '[%s] DISCONNECTED', socket.handshake.address
          return

        onConnect socket, io, client
        console.info '[%s] CONNECTED', socket.handshake.address

      return
