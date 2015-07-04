'use strict'

angular.module 'rangers'
.service 'profile', ($modal, $timeout) ->
  profile =
    close: ->
      if @modalInstance
        try
          @modalInstance.dismiss()
          @modalInstance = null

    open: ->
      @modalInstance = $modal.open
        templateUrl: 'app/controllers/profile-modal.controller.html'
        size: 'lg'
        windowClass: 'profile-modal-controller'
        controller: 'ProfileModalController'
        controllerAs: 'vm'
        bindToController: true

  profile