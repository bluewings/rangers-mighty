'use strict'

express = require('express')
game = require('./game.controller')
router = express.Router()

router.get '/', (req, res, next) ->
  game.query (err, games) ->
    if err
      next err
    else
      arr = []
      Object.keys(games).forEach (key) ->
        arr.push games[key]
        return
      res.json arr
    return
  return

module.exports = router
