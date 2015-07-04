'use strict'

angular.module 'rangers'
.controller 'ProfileModalController', ($scope, $modalInstance) ->
  vm = @

  console.log 'done'

  vm.close = ->
    $modalInstance.dismiss()
    return

  # vm.user = currentUser

  # if vm.user
  #   return
  #   $timeout ->
  #     $state.go 'lobby'
  #     return
  #   , 1

  vm