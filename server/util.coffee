'use strict'

glob = require('glob')

characters = null
stages = null

module.exports =

  # get stored character images
  getRangers: (callback) ->
    if typeof callback isnt 'function'
      callback = ->

    if rangers
      callback(null, rangers)
    else
      glob __dirname + '/../public/assets/rangers/*.png', (err, files) ->
        if err
          callback(err)
        else
          rangers = []
          for file in files
            file = file.replace(/^.*\//, '')
            if file.search(/s\-leonard\-/) is -1
              rangers.push file
          callback(null, rangers)
    return

  # get stored stage images
  getStages: (callback) ->
    if typeof callback isnt 'function'
      callback = ->

    if stages
      callback(null, stages)
    else
      glob __dirname + '/../public/assets/stages/*.png', (err, files) ->
        if err
          callback(err)
        else
          stages = []
          for file in files
            file = file.replace(/^.*\//, '')
            stages.push file
          callback(null, stages)
    return