'use strict'

angular.module 'rangers'
.directive 'simpleChat', ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/simple-chat.directive.html'
  scope: true
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $http, mySocket, profile, Auth, $state) ->
    vm = @

    vm.messages = []

    # profile.open()

    vm.user = Auth.getCurrentUser()

    characters = []
    $http.get '/api/games/characters'
    .success (_characters) ->
      characters = _characters
      return
    
    vm.shuffle = ->
      vm.user.character = characters[parseInt(Math.random() * characters.length, 10)]
      return

    vm.snapshot = JSON.stringify(vm.user)
    vm.update = ->
      vm.user.$update (user) ->
        vm.snapshot = JSON.stringify(vm.user)
      # console.log vm.user
      return

    $scope.$watch 'vm.user', (user) ->
      if user
        vm._snapshot = JSON.stringify(vm.user)
    , true






    vm.socketStat = mySocket.stat

    vm.auth = 
      logout: ->
        Auth.logout ->
          $state.go 'home'    

    vm.sendMessage = ->
      if vm.message
        mySocket.emit 'message', vm.message
        vm.message = ''
      return

    vm.createRoom = ->
      if vm.roomName
        mySocket.emit 'room.create', 
          name: vm.roomName
        vm.roomName = ''
      return

    vm.joinRoom = (room) ->      
      mySocket.emit 'room.join', room.id
      return

    vm.leaveRoom = (room) ->      
      mySocket.emit 'room.leave', room.id
      return

    mySocket.on 'message', (message) ->

      vm.messages.push message
      return

    # mySocket.on 


  


    mySocket.on 'socketInfo', (socketData) ->

      vm.socketData = socketData
      delete socketData.nsps
      delete socketData.sockets
      # delete socketData.eio
      delete socketData.httpServer
      delete socketData.engine
      # delete socketData.server
      # delete socketData.adapter
      # delete socketData.client
      # delete socketData.conn
      console.log socketData
      # console.log arguments
      # console.log event
    
    return