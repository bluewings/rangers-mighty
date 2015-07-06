'use strict'

events = require('events')

class SocketDelegate
  constructor: ->

SocketDelegate.prototype = Object.create(events.EventEmitter.prototype)

socket = new SocketDelegate()

socketDelegate = new SocketDelegate()



socketDelegate.on '_message', (arg1, arg2) ->

  io.to(@)


test =
  listeners: {}
  addListener: (client) ->

    unless @listeners[client.id]
      listener =
        socket: client.socket()
        eventName: '_message'
        callback: (message) ->
          args = [message.type]
          args.concat message.data
          socketDelegate.apply socketDelegate, args
      listener.socket.on listener.eventName, listener.callback
      @listeners[socket.id] listener

  removeListener: (client) ->
    listener = @listeners[client.id]
    listener.socket.removeListener listener.eventName, listener.callback
    delete @listeners[client.id]











deliverMessage = (message) ->
  socketDelegate.emit 'message', {
    socketId: socket.id
    message: message    
  }

regSocket = (socket) ->

  socket.on 'message', deliverMessage

unregSocket = 
  socket.removeListener 'message', deliverMessage











test = 
  listeners: {}

  on: (eventName, callback) ->

    socket.on(eventName, callback)
    unless @listeners[eventName]
      @listeners[eventName] = []
    @listeners[eventName].push callback
    return

  off: (eventName) ->

    if @listeners[eventName]

      for callback in @listeners[eventName]
        socket.removeListener eventName, callback

    return




test.on 'test', (data) ->



  console.log '>>> get message : ' + data

socket.emit 'test', 'test message'

test.off 'test'

socket.emit 'test', 'test message 2'
