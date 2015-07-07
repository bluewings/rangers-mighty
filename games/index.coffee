'use strict'

glob = require('glob')

cached = games: null

query = (callback) ->
  if typeof callback isnt 'function'
    callback = ->

  if cached.games
    callback cached.games
  else
    glob __dirname + '/*/index.coffee', (err, files) ->
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
        callback cached.games
      return
  return

get = (id, callback) ->
  if typeof callback isnt 'function'
    callback = ->

  query (games) ->
    callback games[id]
    return
  return

query()

module.exports =
  query: query
  get: get
