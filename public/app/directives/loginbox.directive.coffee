'use strict'

angular.module 'rangers'
.directive 'loginbox', ->
  restrict: 'EA'
  replace: true
  templateUrl: 'app/directives/loginbox.directive.html'
  scope:
    user: '=user'
    character: '=character'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $state, $timeout, Auth) ->
    vm = @

    vm.character = vm.user.character if vm.user

    vm.auth =
      logout: ->
        Auth.logout()
        vm.user = null

    $timeout ->
      vm.animate = true
      return

    # $timeout ->
    #   if vm.user
    #     $state.go 'lounge'
    # , 2500

    return

  link: (scope, element, attrs) ->
    canvas = $(element).find('canvas').get(0)
    ctx = canvas.getContext('2d')

    img = document.createElement('img')
    img.onload = ->
      padding = 10
      cWidth = canvas.width - padding * 2
      cHeight = canvas.height - padding * 2

      if cWidth / cHeight > img.width / img.height
        h = cHeight
        w = parseInt(h * img.width / img.height, 10)
        x = parseInt((cWidth - w) / 2, 10) + padding
        y = 0 + padding
      else
        w = cWidth
        h = parseInt(w * img.height / img.width, 10)
        x = 0 + padding
        y = parseInt((cHeight - h) / 2, 10) + padding

      # 좌표 정보
      setTimeout ->
        scope.$apply ->
          scope.vm.metric = 
            x: x, y: y, w: w, h: h, rotate: parseInt(Math.random() * 30 - 15)
      , 500

      # 리사이즈된 이미지를 그린다.
      ctx.drawImage img, 0, 0, img.width, img.height, x, y, w, h

      # 이미지 데이터를 추출한 뒤, 색상 정보를 변환해서 다시 그린다.
      imageData = ctx.getImageData(x, y, w, h)
      data = imageData.data
      i = 0
      shadow = minX: null, maxX: null, minY: null, maxY: null
      while i < data.length
        _x = Math.floor(i / 4) % w
        _y = ((i / 4) - _x) / w
        # console.log data[i], data[i + 1], data[i + 2]
        # 그림자 숨김처리 하위 1/3 아래에 있으면서 투명도가 100 이하인 경우 그림자로 간주
        # if _y > h * .67 and data[i + 3] < 100 and data[i] is 0 and data[i + 1] is 0 and data[i + 2] is 0
        if _y > h * .67 and data[i + 3] < 100 and data[i] is 0 and data[i + 1] is 0 and data[i + 2] is 0
          data[i + 3] = 0
          # TODO 그림자 영역 계산은 개선 필요 (개별 점이 아니라 주변값을 참고해야함)
          if shadow.minX > _x or shadow.minX is null
            shadow.minX = _x
          if shadow.maxX < _x or shadow.maxX is null
            shadow.maxX = _x
          if shadow.minY > _y or shadow.minY is null
            shadow.minY = _y
          if shadow.maxY < _y or shadow.maxY is null
            shadow.maxY = _y
        # 전체 색상을 흰색으로 처ㄹ
        data[i] = 255
        data[i + 1] = 255
        data[i + 2] = 255
        i += 4
      ctx.putImageData imageData, x, y

      # 그림자가 포함된 이미지를 그린다.
      convertedImg = document.createElement('img')
      convertedImg.onload = ->
        ctx.clearRect 0, 0, canvas.width, canvas.height
        ctx.shadowColor = 'rgba(0,0,0,.15)'
        ctx.shadowOffsetX = 0;
        ctx.shadowOffsetY = -3;
        ctx.shadowBlur = 1;
        ctx.drawImage convertedImg, 0, 0
        return

      convertedImg.src = canvas.toDataURL()
      return

    img.src = "/assets/rangers/#{scope.vm.character}"
    return

    


