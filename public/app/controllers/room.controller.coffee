'use strict'

angular.module 'rangers'
.controller 'RoomController', ($scope, $state, user, rangers, stages) ->  
  vm = @

  vm.state = $state.current
  console.log $scope

  vm.user = user
  vm.ranger = rangers[Math.floor(Math.random() * rangers.length)]
  vm.stage = stages[Math.floor(Math.random() * stages.length)]

  return