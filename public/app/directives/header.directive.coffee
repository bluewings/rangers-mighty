'use strict'

angular.module 'rangers'
.directive 'header', ->
  restrict: 'A'
  replace: true
  templateUrl: 'app/directives/header.directive.html'
  scope: true
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $rootScope, $state, $timeout, $modal, Auth, config, profile) ->
  # controller: ($scope, $rootScope, $state, $timeout, config, device, Auth) ->


    vm = @

    vm.user = Auth.getCurrentUser()

    vm.auth = 
      logout: ->
        Auth.logout ->
          $state.go 'home'

    vm.open = ->
      profile.open()




      # $modal.open
      #   templateUrl: 'app/controllers/profile-modal.controller.html'
      #   size: 'lg'
      #   windowClass: 'profile-modal-controller'
      #   controller: 'ProfileModalController'
      #   controllerAs: 'vm'
      #   bindToController: true


    return

    vm.navScrollOptions =
      bUseHScroll: true
      bUseVScroll: false
      bUseScrollbar: false

    vm.floatingOptions =
      when: 'phone+portrait'

    vm.navs = [
      { title: '클릭초이스', sref: 'clickchoice', gnb: 'clickchoice' }
      { title: '주요키워드관리', sref: 'clickchoice.adbundles', gnb: 'adbundle' }
      { title: '계정정보', sref: 'account', gnb: 'account' }
    ]

    if config.debug
      vm.navs.push { title: 'API', extern: 'http://10.113.187.116:9010/' }

    vm.openBookmark = ->
      bookmark.open()

      # #61 [QA][갤노트4 4.4.4,5.0.1>시스템 브라우저]즐겨찾기 페이지 노출후 하단페이지 딤드처리되지않습니다.
      # http://yobi.navercorp.com/SADEVLAB/steve-rangers/issue/61
      if device.getNickname() is device.NICK.SAMSUNG_GALAXY_NOTE_4
        backdropFallback = ->
          backdrop = $('.modal-backdrop')
          backdrop.css('display', 'none')
          setTimeout ->
            backdrop.css('display', 'block')          

        setTimeout ->
          backdrop = $('.modal-backdrop')
          backdrop.one 'transitionend', backdropFallback
          backdropFallback()
        , 500

      return

    scrollTimer = []

    scrollToCurrentMenu = ->
      if vm and vm.element and vm.element.find('ul > li.active').size() is 1
        rect = vm.element.find('ul > li.active').get(0).getBoundingClientRect()
        if vm.navScrollOptions.jScroll
          left = null
          if rect.left < 0
            pos = vm.navScrollOptions.jScroll.getCurrentPos()
            left = pos.nLeft - rect.left
          else if rect.right > document.documentElement.clientWidth
            pos = vm.navScrollOptions.jScroll.getCurrentPos()
            left = pos.nLeft - rect.right + document.documentElement.clientWidth
          if left
            vm.navScrollOptions.jScroll.scrollTo left, 0, 500
            while scrollTimer.length > 0
              timer = scrollTimer.shift()
              $timeout.cancel timer

    setNavActive = ->
      for nav in vm.navs
        if $state.current.gnb is nav.gnb
          nav.active = true
        else
          nav.active = false

      scrollTimer = []
      scrollTimer.push $timeout(scrollToCurrentMenu, 150)
      scrollTimer.push $timeout(scrollToCurrentMenu, 350)
      scrollTimer.push $timeout(scrollToCurrentMenu, 700)

    setNavActive()

    unbind = $rootScope.$on '$stateChangeSuccess', setNavActive

    $scope.$on '$destroy', unbind

    return

  link: (scope, element, attrs, vm) ->
    vm.element = element

    return