'use strict'

glob = require('glob')

cached =
  rangers: null
  stages: null

controller =

  # get stored character images
  getRangers: (callback) ->
    if typeof callback isnt 'function'
      callback = ->

    if cached.rangers
      callback(null, cached.rangers)
    else
      glob __dirname + '/../../../public/assets/rangers/*.png', (err, files) ->
        if err
          callback(err)
        else
          cached.rangers = []
          for file in files
            file = file.replace(/^.*\//, '')
            if file.search(/s\-leonard\-/) is -1
              cached.rangers.push file
          callback(null, cached.rangers)
        return
    return

  # get stored stage images
  getStages: (callback) ->
    if typeof callback isnt 'function'
      callback = ->

    if cached.stages
      callback(null, cached.stages)
    else
      glob __dirname + '/../../../public/assets/stages/*.png', (err, files) ->
        if err
          callback(err)
        else
          cached.stages = []
          for file in files
            file = file.replace(/^.*\//, '')
            cached.stages.push file
          callback(null, cached.stages)
        return
    return

module.exports = controller
