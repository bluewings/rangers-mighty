'use strict'

angular.module 'rangers'
.controller 'LoungeController', ($scope, $state, user, rangers, stages) ->  
  vm = @

  vm.state = $state.current

  vm.user = user
  vm.ranger = rangers[Math.floor(Math.random() * rangers.length)]
  vm.stage = stages[Math.floor(Math.random() * stages.length)]

  return