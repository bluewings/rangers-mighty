'use strict'

angular.module 'rangers'
.controller 'HomeController', ($scope, $window, $state, $modal, $timeout, currentUser, characters) ->  
  vm = @

  vm.user = currentUser
  vm.character = characters[parseInt(Math.random() * characters.length, 10)]

  win = $(window)



  resizeHandler = ->
    vm.minHeight = window.innerHeight
    return


  resizeHandler()


  win.on 'resize.home-control', ->
    $timeout ->
      resizeHandler()
      return
    return




  vm.open = ->

    $modal.open
      templateUrl: 'app/controllers/profile-modal.controller.html'
      size: 'lg'
      windowClass: 'profile-modal-controller'
      controller: 'ProfileModalController'
      controllerAs: 'vm'
      bindToController: true

  if vm.user
    return
    $timeout ->
      $state.go 'lobby'
      return
    , 1



  return