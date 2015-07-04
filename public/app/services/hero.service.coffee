'use strict'

cloneElem = (elem) ->
  cloned = elem.clone()
  cloned.removeAttr('hero')
  cloned.css
    top: 0
    left: 0
    opacity: 1

  cloned

heroTransition =
  dict: {}
  prepare: ($rootScope, $timeout) ->

    my = @

    dict = {}

    return

    getBoundingClientRect = (elem) ->
      elem = $(elem)

      rect = elem.get(0).getBoundingClientRect()
      pRect = elem.closest('[ui-view]').get(0).getBoundingClientRect()

      console.log rect
      console.log pRect

      # rect.top -= pRect.top
      # rect.left -= pRect.left

      top: rect.top - pRect.top
      left: rect.left - pRect.left
      width: rect.width
      height: rect.height
      bottom: rect.bottom - pRect.top
      right: rect.right - pRect.left







    transit = (def) ->

      hero = def

      hero.target.elem.css 'opacity', 0

      # 타겟이 늦게 준비되는 상황 고려

      

      $timeout ->

        hero.target.cloned = cloneElem(hero.target.elem)
        hero.source.rect = getBoundingClientRect(hero.source.elem)
        hero.target.rect = getBoundingClientRect(hero.target.elem)



        def.ghost = $('<div class="hero-ghost"></div>')
        # # # console.log 'found : ' + name
        $(document.body).append def.ghost
        def.ghost.append def.source.cloned.addClass('hero-source')
        def.ghost.append def.target.cloned.addClass('hero-target')




        hero.ghost.css
          
          transform: "translate3d(#{hero.source.rect.left}px,#{hero.source.rect.top}px,0)"
          # transition: 'all 1s ease-in-out'
        hero.ghost.one 'transitionend', (event) ->
          hero.target.elem.css 'opacity', 1
          hero.ghost.remove()

        # hero.target.elem.css 'opacity', 0
        hero.source.elem.css 'opacity', 0
        hero.source.cloned.css
          # top: 0
          # left: 0
          transform: 'scale(1,1)'
          opacity: 1



        hero.target.cloned.css
          # top: 0
          # left: 0

          transform: "scale(#{hero.source.rect.width/hero.target.rect.width},#{hero.source.rect.height/hero.target.rect.height})"
          opacity: 0

        $timeout ->
          hero.ghost.addClass 'animate'
          hero.ghost.css
            transform: "translate3d(#{hero.target.rect.left}px,#{hero.target.rect.top}px,0)"


          hero.source.cloned.css
            transform: "scale(#{hero.target.rect.width/hero.source.rect.width},#{hero.target.rect.height/hero.source.rect.height})"
            opacity: 0

          hero.target.cloned.css
            transform: 'scale(1,1)'
            opacity: 1


      , 1

    $rootScope.$on '$stateChangeSuccess', ->
      # # console.log '$stateChangeSuccess'

      postJob()

    postJob = ->
      view = $('[ui-view]').not('[prev-view]')

      # # console.log view.find('[hero]').size()
      # # console.log $('[ui-view]').find('[hero]').size()
      # # console.log $('[ui-view]').find('[hero]').get(0).outerHTML

      $timeout ->


        view.find('[hero]').not('[done]').each (index, item) ->

          item = $(item)
          name = item.attr('done', 1).attr('hero')
          if dict[name] and dict[name].source and !dict[name].target
            dict[name].target = 
              elem: item
              cloned: cloneElem(item)
              rect: item.get(0).getBoundingClientRect()

            transit dict[name]

        # .attr('curr-view', true)


      # # # console.log arguments
    $rootScope.$on '$stateChangeStart', ->
      # # console.log '$stateChangeStart'


      dict = {}
      view = $('[ui-view]')

      $('.hero-ghost').remove()



      view.find('[hero]').each (index, item) ->

        item = $(item)
        name = item.attr('hero')
        dict[name] =
          source:
            elem: item
            cloned: cloneElem(item)
            rect: item.get(0).getBoundingClientRect()




      view.attr('prev-view', true)
      # # # console.log arguments

      return
      for name of my.dict


        # # # console.log name

        source = my.dict[name].source


        source.cloned = cloneElem(source.elem)
        source.rect = source.elem.get(0).getBoundingClientRect()
        # # console.log '>>> html'
        # # console.log source.elem.html()
        # # console.log source.rect.top, source.rect.left
      $('[ui-view]').attr('prev-view', true)

      # for name of my.dict
      #   hero = my.dict[name].closest('')








    $rootScope.$on '$viewContentLoaded', ->
      # # console.log '$viewContentLoaded'
      postJob()
      # # # console.log arguments

    $rootScope.$on '$viewContentLoading', ->
      # # console.log '$viewContentLoading'
      # # # console.log arguments


    @prepare = ->

angular.module 'rangers'
.directive 'hero', ->
  restrict: 'A'
  controller: ($scope, $element, $rootScope, $state, $timeout, $modal, Auth, config, profile) ->
    name = $element.attr('hero')



    # # # console.log name


    heroTransition.prepare $rootScope, $timeout

    return

    hero = heroTransition.dict[name]
    unless hero


      hero = heroTransition.dict[name] = 
        source:
          elem: $($element)
          cloned: null
          rect: null
        target:
          elem: null
          cloned: null
          rect: null
        ghost: $('<div class="hero-ghost"></div>')

      $(document.body).append hero.ghost

    else
      hero.target.elem = $($element)
      hero.target.cloned = cloneElem(hero.target.elem)
      hero.target.rect = hero.target.elem.get(0).getBoundingClientRect()

      hero.ghost.append hero.source.cloned.addClass('hero-source')
      hero.ghost.append hero.target.cloned.addClass('hero-target')
      hero.ghost.removeClass 'animate'
      hero.ghost.css
        
        transform: "translate3d(#{hero.source.rect.left}px,#{hero.source.rect.top}px,0)"
        # transition: 'all 1s ease-in-out'
      
      hero.source.cloned.css
      
        transform: 'scale(1,1)'
        opacity: 1



      hero.target.cloned.css

        transform: "scale(#{hero.source.rect.width/hero.target.rect.width},#{hero.source.rect.height/hero.target.rect.height})"
        opacity: 0

      hero.target.elem.css
        opacity: 0

      hero.ghost.one 'transitionend', (event) ->
        hero.target.elem.css 'opacity', 1
        hero.source = hero.target
        hero.target = {}
        hero.ghost.empty()
        return


      setTimeout ->

        hero.target.rect = hero.target.elem.get(0).getBoundingClientRect()

        hero.ghost.addClass 'animate'
        hero.ghost.css
          transform: "translate3d(#{hero.target.rect.left}px,#{hero.target.rect.top}px,0)"


        hero.source.cloned.css
          transform: "scale(#{hero.target.rect.width/hero.source.rect.width},#{hero.target.rect.height/hero.source.rect.height})"
          opacity: 0

        hero.target.cloned.css
          transform: 'scale(1,1)'
          opacity: 1
      , 100

      return

      setTimeout ->
        # alert '1'
        hero.source.cloned.css
        
          transformOrigin: '0 0'
          transform: 'scale(1,1)'
          opacity: 1



        hero.target.cloned.css
          position: 'absolute'
          top: 0
          left: 0
          transition: 'all 1s ease-in-out'
          transformOrigin: '0 0'
          transform: "scale(#{hero.source.rect.width/hero.target.rect.width},#{hero.source.rect.height/hero.target.rect.height})"
          opacity: 0

        hero.target.elem.css
          opacity: 0

        hero.ghost.one 'transitionend', (event) ->
          return
          hero.target.elem.css 'opacity', 1
          hero.source = hero.target
          hero.target = {}
          hero.ghost.empty()
          return

        setTimeout ->
          return
          transforms = []
          # transforms.push "translate3d(#{hero.target.rect.left}px,#{hero.target.rect.top}px,0)"
          hero.ghost.css
            transform: "translate3d(#{hero.target.rect.left}px,#{hero.target.rect.top}px,0)"

          hero.source.cloned.css
            transform: "scale(#{hero.target.rect.width/hero.source.rect.width},#{hero.target.rect.height/hero.source.rect.height})"
            opacity: 0

          hero.target.cloned.css
            transform: 'scale(1,1)'
            opacity: 1

        , 100
      # # console.log 'found you'
      # # console.log hero.source.rect.top + ' x ' + hero.source.rect.left + ' -> ' +
        hero.target.rect.top + ' x ' + hero.target.rect.left






    return