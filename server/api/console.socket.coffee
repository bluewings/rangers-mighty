true
###*
Broadcast updates to client when the model changes
###

#var thing = require('./thing.model');
uid = ->
  (parseInt(Math.random() * 900000000 + 100000000, 10)).toString(36).substr 0, 6
'use strict'
users = {}
windows = {}
exports.register = (socket, socketio) ->
  socketio.on 'connection', (socket) ->
    users[socket.id] = id: socket.id
    console.log '>> connected'
    console.log users
    socket.on 'disconnect', ->
      delete users[socket.id]

      console.log '>> disconnected'
      console.log users
      return

    return

  socket.on 'console:ping', (data) ->
    newObj = {}
    for key of socket
      newObj[key] = socket[key]  if socket.hasOwnProperty(key) and typeof socket[key] isnt 'object'
    socket.emit 'console:ping',
      id: socket.id
      socket: newObj

    return

  socket.on 'console:tab.create', (data) ->
    console.info '[message][%s] %s', socket.address, JSON.stringify(data, null, 2)
    tabId = uid()
    socket.emit 'console:tab.create',
      id: tabId
      name: 'new Tab'

    return

  socket.on 'console:message', (data) ->
    console.info '[message][%s] %s', socket.address, JSON.stringify(data, null, 2)
    socketio.emit 'console:message', data.message
    return

  return

#
#  thing.schema.post('save', function (doc) {
#    onSave(socket, doc);
#  });
#  thing.schema.post('remove', function (doc) {
#    onRemove(socket, doc);
#  });
#  

#
#function onSave(socket, doc, cb) {
#  socket.emit('thing:save', doc);
#}
#
#function onRemove(socket, doc, cb) {
#  socket.emit('thing:remove', doc);
#}
#
