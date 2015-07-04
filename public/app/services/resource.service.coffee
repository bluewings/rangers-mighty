'use strict'

app = angular.module 'rangers'
.service 'resource', ($q, $http) ->
  data =
    rangers: null
    stages: null
  rangers: do ->
    deferred = $q.defer()
    if data.rangers
      deferred.resolve rangers
    else
      $http.get '/api/resources/rangers'
      .success (rangers) ->
        deferred.resolve rangers
        data.rangers = rangers
      .error (err) ->
        deferred.reject null
    deferred.promise

  stages: do ->
    deferred = $q.defer()
    if data.rangers
      deferred.resolve rangers
    else
      $http.get '/api/resources/stages'
      .success (rangers) ->
        deferred.resolve rangers
        data.rangers = rangers
      .error (err) ->
        deferred.reject null
    deferred.promise