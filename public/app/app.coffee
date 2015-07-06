'use strict'

angular.module 'rangers', [
  'ngAnimate'
  'ngCookies'
  'ngResource'
  'ngSanitize'
  'ui.bootstrap'
  'ui.router'
  'angular-jwt'
  'btford.socket-io'
  'alAngularHero'
  'config'
]
.config ($urlRouterProvider, $stateProvider, $httpProvider, jwtInterceptorProvider) ->

  $urlRouterProvider.otherwise '/'

  $stateProvider.state 'front',
    url: '/'
    templateUrl: 'app/controllers/front.controller.html'
    controller: 'FrontController'
    controllerAs: 'vm'
    resolve:
      user: ($q, Auth) ->
        deferred = $q.defer()
        Auth.isLoggedInAsync (loggedIn) ->
          if loggedIn
            deferred.resolve Auth.getCurrentUser()
          else
            deferred.resolve null
          return
        deferred.promise

      rangers: (resource) ->
        resource.rangers

      stages: (resource) ->
        resource.stages

  $stateProvider.state 'lounge',
    url: '/lounge'
    templateUrl: 'app/controllers/lounge.controller.html'
    controller: 'LoungeController'
    controllerAs: 'vm'
    resolve:
      user: ($q, Auth) ->
        deferred = $q.defer()
        Auth.isLoggedInAsync (loggedIn) ->
          if loggedIn
            deferred.resolve Auth.getCurrentUser()
          else
            deferred.resolve null
          return
        deferred.promise

      rangers: (resource) ->
        resource.rangers

      stages: (resource) ->
        resource.stages

      games: ($q, Game) ->
        deferred = $q.defer()
        Game.query (games) ->
          deferred.resolve games
        , (err) ->
          deferred.reject err
        deferred.promise

  $stateProvider.state 'room',
    url: '/room'
    templateUrl: 'app/controllers/room.controller.html'
    controller: 'RoomController'
    controllerAs: 'vm'
    resolve:
      user: ($q, Auth) ->
        deferred = $q.defer()
        Auth.isLoggedInAsync (loggedIn) ->
          if loggedIn
            deferred.resolve Auth.getCurrentUser()
          else
            deferred.resolve null
          return
        deferred.promise

      rangers: (resource) ->
        resource.rangers

      stages: (resource) ->
        resource.stages

  $stateProvider.state 'lobby',
    url: '/lobby'
    # parent: 'wrap'
    templateUrl: 'app/controllers/lobby.controller.html'
    controller: 'LobbyController'
    controllerAs: 'vm'
    # authenticate: true

  $stateProvider.state 'lobby2',
    url: '/lobby2'
    parent: 'wrap'
    templateUrl: 'app/controllers/lobby2.controller.html'
    controller: 'Lobby2Controller'
    controllerAs: 'vm'
    # authenticate: true
    resolve:
      currentUser: (Auth, $q) ->
        deferred = $q.defer()
        Auth.isLoggedInAsync (loggedIn) ->
          if loggedIn
            deferred.resolve Auth.getCurrentUser()
          else
            deferred.resolve null
          return
        deferred.promise

  # set JWT token
  $httpProvider.interceptors.push 'jwtInterceptor'
  jwtInterceptorProvider.tokenGetter = ($cookieStore) ->
    $cookieStore.get 'token'
  return

.run ($rootScope, $state, $window, $timeout, $http, Auth) ->

  resizeHandler = ->
    $rootScope.clientWidth = document.documentElement.clientWidth
    $rootScope.clientHeight = document.documentElement.clientHeight
    return

  $($window).on 'resize', (event) ->
    $timeout resizeHandler
    return

    # $rootScope.clientWidth = document.
  resizeHandler()


  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->


    transition = ''

    fromName = fromState.name
    toName = toState.name

    if fromName is 'front'
      if toName is 'lounge'
        transition = 'slide-left'

    if fromName is 'lounge'
      if toName is 'front'
        transition = 'slide-right'
      else if toName is 'room'
        transition = 'slide-up'
      else if toName is 'lobby'
        transition = 'slide-down'

    if fromName is 'room'
      if toName is 'lounge'
        transition = 'slide-down'

    if fromName is 'lobby'
      if toName is 'lounge'
        transition = 'slide-up'

    
      
        
      
        
      # if fromName is 'lobby'
      #   transition = 'slide-up'

    # if toName is 'lobby'
    #   if fromName is 'lounge'
    #     transition = 'slide-down'


    
    # if transition
    $rootScope.transition = transition

    # alert transition

    # $rootScope.prevState = fromName
    
  
  $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
    return

    $rootScope.prevState = fromState.name
    $rootScope.currState = toState.name
    $rootScope.nextState = toState.name

    $rootScope.fromState = fromState.name
    $rootScope.toState = toState.name


    console.log transition
    # if fromState.name is 'lounge'
    #   if toState.name is 'room'
    #     transition = 'slide-left'
    
    # console.log('Previous state:'+$rootScope.previousState)
    # console.log('Current state:'+$rootScope.currentState)
# });

  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    # console.log 'check 1 : ' + $('[ui-view] [hero]').size()
    Auth.isLoggedInAsync (loggedIn) ->
      if toState.authenticate and not loggedIn
        event.preventDefault()
        Auth.logout -> $state.go 'home'
      else
        # console.log 'check 2 : ' + $('[ui-view] [hero]').size()
      return
    return

  $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->

    $timeout ->
      $rootScope.current = toState
    # console.log 'check 3 : ' + $('[ui-view] [hero]').size()
    return

  # hero = null
  heroes = {}

  $rootScope.$on '$viewContentLoading', ->
    return

    heroes = {}

    $('[ui-view]').attr('expired-view', 1)
    $('[ui-view] [hero]').each (index, item) ->


      name = item.getAttribute('hero')
      $(item).parents('[ui-view]').attr('expired-view', 1)
      heroes[name] = 
        clone: $(item).clone()
        rect: item.getBoundingClientRect()
      # # console.log name

      



    # console.log '>> we are heroes'
    # console.log heroes



    # if hero
    #   cloned =
    #     el: hero.clone()
    #     name

    # else
    #   cloned = null
      
    # # console.log 'check 4 ui-view : ' + $('[ui-view]').size()
    # # console.log 'check 4 hero : ' + $('[ui-view] [hero]').size()


  $rootScope.$on '$viewContentLoaded', ->
    $('[ui-view]').each (index, item) ->

      item = $(item)
      return if item.attr('expired-view')

      item.find('[hero]').each (i, hero) ->
        name = hero.getAttribute('hero')
        
        if heroes[name]
          # console.log '%chero found.', 'font-size:20px'

          elemId = "hero-#{name}"

          $("##{elemId}").remove()

          $(document.body).append heroes[name].clone
          rect = heroes[name].rect

          heroes[name].clone.attr
            id: elemId
          .css
            position: 'absolute'
            top: 0
            left: 0
            zIndex: 10000
            transform: "translateX(#{rect.left}px) translateY(#{rect.top}px)"

          rect = hero.getBoundingClientRect()
          heroes[name].clone.css
            transition: 'all .75s ease-in-out'
            transform: "translateX(#{rect.left}px) translateY(#{rect.top}px)"
          
          clone = heroes[name].clone
          heroes[name].clone.one 'transitionend', ->
            clone.remove()



          # console.log "translateX(#{rect.left}px)"


      heroes = {}


      # # console.log 'valid view!!!'


    # .attr('expired-view', 1)
    # # console.log 'check 5 ui-view : ' + $('[ui-view]').size()
    # # console.log 'check 5 hero : ' + $('[ui-view] [hero]').size()

  return