'use strict'

angular.module 'rangers'
.directive 'trianglify', ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    classId = 'trianglify-' + parseInt(Math.random() * 100000, 10)
    style = document.createElement('style')
    element.append(style)
    element.addClass(classId)
    colors = [
      'YlGnBu'
      'YlOrRd'
      'GnBu'
      'YlOrBr'
      'Purples'
      'Blues'
      'Oranges'
      'Reds'
      'PuRd'
    ]
    pattern = Trianglify({
      # width: window.innerWidth, 
      # height: window.innerHeight
      width: element.outerWidth()
      height: element.outerHeight()
      
      x_colors: colors[parseInt(Math.random() * colors.length, 10)]
    })
    styles = []
    styles.push ".#{classId} {"  
    styles.push "background:url(#{pattern.canvas().toDataURL()});"
    styles.push 'background-size:cover;'
    styles.push 'background-position:50% 0;'
    styles.push "}"
    style.innerHTML = styles.join('')
    return