'use strict'

angular.module 'rangers'
.controller 'WrapController', ($scope, $rootScope, $state, $timeout, config) ->
  vm = @
  vm.config = config

  vm.animate = false  
  vm.showAsideLeft = false
  vm.showAsideRight = false

  vm.menus = [
    { gnb: 'manager', state: 'manager', label: '광고 관리' }
    { gnb: 'account', state: 'account', label: '계정 설정' }
    { gnb: '', state: 'test', label: '청구서' }
  ]

  vm.toggleLeft = ->
    vm.showAsideLeft = if vm.showAsideLeft then false else true
  
  vm.toggleRight = ->
    vm.showAsideRight = if vm.showAsideRight then false else true

  $timeout ->
    vm.animate = true
  , 500

                # li.active
                #   a(href='', ui-sref='manager')
                #     | 광고 관리
                #     span.sr-only (current)
                # li
                #   a(href='', ui-sref='account') 계정 설정
                # li
                #   a(href='') 청구서  

  syncGnb = ->
    # console.log $state.current
    vm.state = $state.current
    # for nav in vm.navs
    #   if $state.current.gnb is nav.gnb
    #     nav.active = true
    #   else
    #     nav.active = false

    # scrollTimer = []
    # scrollTimer.push $timeout(scrollToCurrentMenu, 150)
    # scrollTimer.push $timeout(scrollToCurrentMenu, 350)
    # scrollTimer.push $timeout(scrollToCurrentMenu, 700)

  syncGnb()

  unbind = $rootScope.$on '$stateChangeSuccess', syncGnb

  $scope.$on '$destroy', unbind

  return