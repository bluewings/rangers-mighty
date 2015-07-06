'use strict'

angular.module 'rangers'
.controller 'LoungeController', ($scope, $element, $timeout, $state, user, rangers, stages, mySocket, $interval, games) ->  
  vm = @

  vm.state = $state.current

  vm.user = user
  vm.ranger = rangers[Math.floor(Math.random() * rangers.length)]
  vm.stage = stages[Math.floor(Math.random() * stages.length)]

  vm.games = games

  vm.socketStat = mySocket.stat

  # vm.messages = [
  #   Math.random()
  #   Math.random()
  #   Math.random()
  #   Math.random()
  #   Math.random()
  # ]

  # $interval ->
  #   if vm.messages.length > 20
  #     vm.messages.unshift()
  #   vm.messages.push Math.random()
  # , 1000

  vm.messages = []

  vm.createGame = (game) ->
    # if vm.roomName
    mySocket.emit 'room.create', 
      name: Math.random()
      gameId: game.id
    # vm.roomName = ''
    return
    return

  vm.joinRoom = (room) ->      
    mySocket.emit 'room.join', room.id
    return

  vm.sendMessage = ->
    if vm.message
      mySocket.emit 'message', vm.message
      vm.message = ''
    return

  mySocket.on 'message', (message) ->

    vm.messages.push message
    # $timeout ->
    messages = $element.find('.messages')
    lists = $element.find('.messages ul')
    console.log messages.scrollTop(), lists.outerHeight(), lists.outerHeight() - messages.scrollTop(), messages.innerHeight()

    if lists.outerHeight() - messages.scrollTop() <= messages.innerHeight()

      setTimeout ->
        messages.stop().animate
          scrollTop: lists.outerHeight() 
      , 10
    else
      
      $timeout ->
        vm.recentMessage = message
      , 3000

    # return

    return




  return