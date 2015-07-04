'use strict'

heroAnimation = ($timeout, $animateCss) ->

  _ = {}
    
  clear = ->
    _.fromScreen = null
    _.toScreen = null
    _.doneList = []


    # Call remove for each animating hero element
    if _.movingList
      _.movingList.forEach (m) ->
        m.remove()
        return
    _.movingList = []

  clear()

  enter = (screen, done) ->
    _.toScreen = screen
    _.doneList.push done
    tryStart()

  leave = (screen, done) ->
    _.fromScreen = screen
    _.doneList.push done
    tryStart()

  tryStart = ->
    if !_.fromScreen or !_.toScreen
      # # console.log '> 1'
      _.startTimer = setTimeout ->
        # # console.log '>>> case 1'
        finish true
        return
      return null
    else
      # # console.log '> 2'
      if _.startTimer
        clearTimeout _.startTimer

      setTimeout start

      cancelled = false

      return ->
        unless cancelled
          cancelled = true
          # # console.log 'canceld'
          clear()

  start = ->

    # # console.log _

    fromHeroes = _.fromScreen[0].querySelectorAll('[hero]')
    toHeroes = _.toScreen[0].querySelectorAll('[hero]')

    pairs = []

    for fromHero in fromHeroes
      for toHero in toHeroes
        if fromHero.getAttribute('hero-id') is toHero.getAttribute('hero-id')
          pairs.push
            from: fromHero
            to: toHero



    # # console.log fromHeroes
    # # console.log toHeroes
    # # console.log pairs

    for pair in pairs
      # # console.log '>>> check pair'
      # # console.log pair

      animateHero angular.element(pair.from), angular.element(pair.to)

    # # console.log '>>> case 2'

    finish()



    # finish()

  animateHero = (fromHero, toHero) ->

    _waits = []

    # if fromHero.is('img?')
      # # console.log fromHero[0].complete, fromHero[0].readyState
    # if toHero.is('img')
      # # console.log toHero[0].complete, toHero[0].readyState

    # fromHero.is('img')



    # console.log fromHero.is('img')

    animateHeroCore(fromHero, toHero)

  animateHeroCore = (fromHero, toHero) ->

    # # console.log fromHero

    fromRect = getScreenRect(fromHero, _.fromScreen)

    moving = $("<div></div>")

    fromHeroClone = fromHero.clone()
    toHeroClone = toHero.clone()
    moving.append fromHeroClone
    moving.append toHeroClone

    fromHero.css 'visibility', 'hidden'
    toHero.css 'visibility', 'hidden'

    fromHeroClone.addClass 'hero-from'
    toHeroClone.addClass 'hero-to'
    

    

    _.fromScreen.parent().append moving

    moving.css
      # backgroundColor: 'lightyellow'
      transform: "translate3d(#{fromRect.left}px, #{fromRect.top}px, 0)"

    .addClass 'hero-animating'

    handler =
      complete: false
      onComplete: ->
        # Allows us to track which animations have finished
        handler.complete = true
        # # console.log '>>> case 3'
        finish()
        return
      remove: ->

        # Show the original target element
        toHero.css('visibility', '')

        # Unbind the event handler and remove the element
        moving.unbind('transitionend', handler.onComplete)
        moving.remove()
        return

    _.movingList.push(handler)

    setTimeout ->

      toRect = getScreenRect(toHero, _.toScreen)



      moving.css({
        transform: "translate3d(#{toRect.left}px, #{toRect.top}px, 0)"
      }).addClass('hero-animating-active')


      fromHeroClone.css
        opacity: 0
        transform: "scale(#{toRect.width / fromRect.width}, #{toRect.height / fromRect.height})"


      toHeroClone.css
        transform: "scale(#{fromRect.width / toRect.width}, #{fromRect.height / toRect.height})"


      # setTimeout ->
        # toHeroClone.addClass 'hero-to'
      # Switch the animating element to the target's classes,
      # which allows us to animate other properties like color,
      # border, corners, etc.
      moving.attr 'class', toHero.attr('class') + ' hero-animating'


      # $timeout ->
      setTimeout ->
        toHeroClone.addClass 'lazy-animate'
        # setTimeout ->
        toHeroClone.css
          opacity: 1
          transform: 'scale(1,1)'
      , 50
   

      moving.bind('transitionend', handler.onComplete)


    , 50








  getScreenRect = (element, screen) ->
    elementRect = element[0].getBoundingClientRect()


    screenRect = screen[0].getBoundingClientRect()
    {
      top: elementRect.top - (screenRect.top)
      left: elementRect.left - (screenRect.left)
      width: elementRect.width
      height: elementRect.height
    }

  finish = (cancelled) ->

    allComplete = true

    # allComplete = false
    unless cancelled
      # # console.log _.movingList
      _.movingList.forEach (m) ->
        allComplete = allComplete and m.complete
        return

    if allComplete
      doneCallbacks = _.doneList.slice(0)
      doneCallbacks.forEach (done) ->
        done()
        return
      clear()



  enter: (element, doneFn) ->
    if $animateCss
      runner = $animateCss(element,
        event: 'enter'
        structural: true
      ).start()
      return enter element, ->
        runner.done doneFn
    else
      return enter element, doneFn

  leave: (element, doneFn) ->
    if $animateCss
      runner = $animateCss(element,
        event: 'leave'
        structural: true
      ).start()
      return leave element, ->
        runner.done doneFn
    else
      return leave element, doneFn


heroAnimation.$inject = ['$timeout']

if angular.version.major >= 1 and angular.version.minor >= 4
  heroAnimation.$inject.push '$animateCss'

angular.module 'rangers'
.animation '.hero-animation', heroAnimation