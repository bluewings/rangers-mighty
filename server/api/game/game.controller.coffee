'use strict'

glob = require('glob')

cached = games: null

controller =

  # get all games
  query: (callback) ->
    if typeof callback isnt 'function'
      callback = ->

    if cached.games
      callback null, cached.games
    else
      glob __dirname + '/../../../games/*/index.coffee', (err, files) ->
        if err
          return callback(err)
        else
          cached.games = {}
          for indexFile in files
            game = require(indexFile)
            gameId = indexFile.replace(/^.*\/([^\/]+)\/.*?$/, '$1')
            if typeof game.factory isnt 'function'
              console.log "[ERR] game '#{gameId}': factory function is not implemented."
            else
              game.option = {} unless game.option
              game.id = gameId
              game.name = game.name or gameId
              cached.games[gameId] = game
          callback null, cached.games
        return
    return

  # get game by id
  get: (id, callback) ->
    if typeof callback isnt 'function'
      callback = ->

    @query (err, games) ->
      callback null, games[id]
      return
    return

controller.query()

module.exports = controller