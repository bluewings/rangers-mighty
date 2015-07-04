'use strict'

express = require('express')
# game = require('../../../game')
glob = require('glob')
util = require('../../util')

router = express.Router()

# router.get '/', (req, res) ->
#   res.json 200, game.getGames(true)
#   return

router.get '/characters', (req, res, next) ->

  util.getRangers (err, rangers) ->    
    if err
      next(err)  
    else
      res.json rangers
    return

router.get '/stages', (req, res, next) ->

  util.getStages (err, stages) ->    
    if err
      next(err)  
    else
      res.json stages
    return

module.exports = router
