'use strict'

angular.module 'rangers'
.directive 'prototype', ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/directives/prototype.directive.html'
  scope: true
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $element, $window, $document) ->
    vm = @

    # canvas = $element.find('canvas').get(0)
    # ctx = canvas.getContext('2d')

    resizeHandler = ->
      return
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight
      ctx.clearRect 0, 0, canvas.width, canvas.height

      pad = 50

      xMid = canvas.width / 2
      yMid = canvas.height / 2

      # ctx.moveTo xMid, pad
      # ctx.bezierCurveTo (xMid + canvas.width - pad) / 2, pad,
      #   canvas.width - pad, (pad + yMid) / 2,
      #   canvas.width - pad, yMid
      # ctx.stroke()


      return

    $($window).on 'resize', (event) ->
      resizeHandler()
      return

    resizeHandler()




    vm.updateBackground = ->


      pattern = Trianglify({
        width: window.innerWidth
        height: window.innerHeight
        x_colors: 'Spectral'
        # x_colors: 'YlGnBu'
      })
      # return
      # $element.find('.background').append pattern.canvas()
      $document.find('body').css
        background: 'url(' + pattern.canvas().toDataURL() + ')'
        backgroundSize: 'cover'
        backgroundPosition: '50% 0'
      console.log 'background set'
      return

    vm.updateBackground()
    
    return
