'use strict'

app = angular.module 'rangers'

app.factory 'Game', ($resource) ->
  $resource '/api/games/:id',
    id: '@id'