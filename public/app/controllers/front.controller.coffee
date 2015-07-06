'use strict'

angular.module 'rangers'
.controller 'TestCtrl', ->
  console.log 'testctrl'
  return
.controller 'FrontController', ($scope, user, rangers, stages) ->  
  vm = @


  vm.user = user
  vm.ranger = rangers[Math.floor(Math.random() * rangers.length)]
  vm.stage = stages[Math.floor(Math.random() * stages.length)]

  return