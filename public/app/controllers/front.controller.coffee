'use strict'

angular.module 'rangers'
.controller 'TestCtrl', ->
  console.log 'testctrl'
  return
.controller 'FrontController', ($scope, $state, user, rangers, stages) ->  
  vm = @

  # vm.previous = $state.
  console.log $state

  vm.state = $state.current

  vm.user = user
  vm.ranger = rangers[Math.floor(Math.random() * rangers.length)]
  vm.stage = stages[Math.floor(Math.random() * stages.length)]

  return