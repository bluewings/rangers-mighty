'use strict'

angular.module 'rangers'
# .controller 'CommonHomeController', ($scope, $element, $window, Auth, $state, $timeout, corsStorage, isLoggedIn, currentUser) ->  
.controller 'LobbyController', ($scope, Auth) ->  
  vm = @

  vm.user = Auth.getCurrentUser()
  return

  console.log '>>> is Logged In'
  console.log isLoggedIn
  console.log currentUser

  vm.user = currentUser

  vm.items = corsStorage.items

  vm.auth =
    getCurrentUser: Auth.getCurrentUser
    isLoggedIn: Auth.isLoggedIn
    login: ->
      vm.onrequest = true
      Auth.login vm.username, vm.password
      , (user) ->
        delete vm.errorMessage
        delete vm.shakeLoginBox 
        $state.go 'clickchoice'
      , (err) ->
        delete vm.onrequest
        if err is null
          vm.errorMessage = 'ERR_CONNECTION_REFUSED'
        else
          vm.errorMessage = '사용자 이름 또는 암호가 잘못되었습니다.'
        vm.shakeLoginBox = true
        $timeout ->
          delete vm.shakeLoginBox 
        , 350
      return
    logout: Auth.logout

  # controller 외부에 이벤트 헨들러를 붙이는 경우,
  # controller 가 파괴되는 경우 이벤트핸들러를 직접 제거해주어야한다.
  # jQuery 에 추가한 $on 함수를 통해 이벤트 붙임.
  # .$on(events, handler, execute, angularDigest)
  unbind = $($window).$on 'resize', (event) ->
    vm.cHeight = document.documentElement.clientHeight
  , true, true

  # controller 의 scope 이 파괴되는 경우 위에서 추가한 이벤트 핸들러를 제거
  $scope.$on '$destroy', unbind


  pattern = Trianglify({
    width: window.innerWidth, 
    height: window.innerHeight
  })
  $element.find('.background').append pattern.canvas()



  return