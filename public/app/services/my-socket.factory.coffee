'use strict'

angular.module 'rangers'
.factory 'mySocket', (socketFactory, $cookieStore) ->
  token = $cookieStore.get 'token'
  if token
    ioSocket = io("?token=#{token}", path: '/socket.io')
    mySocket = socketFactory ioSocket: ioSocket  
  else
    mySocket = socketFactory()

  mySocket.stat = {}

  setStat = ->
    return if !mySocket.stat.me or !mySocket.stat.rooms
    if mySocket.stat.me.room
      mySocket.stat.room = mySocket.stat.rooms[mySocket.stat.me.room]
    else
      mySocket.stat.room = null
    if mySocket.stat.room and mySocket.stat.room.clients and mySocket.stat.clients
      for id, dummy of mySocket.stat.room.clients
        if mySocket.stat.room.clients.hasOwnProperty id
          mySocket.stat.room.clients[id] = mySocket.stat.clients[id]
    return

  mySocket.on 'stat.me', (user) ->

    mySocket.stat.me = user
    mySocket.stat.room = mySocket.stat.me.room
    setStat()
    return

  mySocket.on 'stat.clients', (clients) ->
    # console.log 'stat.client!!!'
    # console.log clients
    mySocket.stat.clients = clients
    setStat()
    return

  mySocket.on 'stat.rooms', (rooms) ->
    # console.log rooms
    if rooms
      for id, room of rooms
        room.clientCount = Object.keys(room.clients).length
    mySocket.stat.rooms = rooms
    setStat()
    return

  mySocket