'use strict'

angular.module 'rangers'
.controller 'GameSampleController', ($scope, socket) ->  
  vm = @

  console.log 'wow i am here'

  vm.submit = ->
    console.log 'submit'
    socket.emit 'message', vm.message, 123, { abc: '111' }
    vm.message = ''

  socket.on 'message', (message) ->
    console.log message

  socket.on 'messagetest', (message) ->
    console.log message


  return