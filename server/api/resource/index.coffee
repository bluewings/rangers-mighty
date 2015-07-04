'use strict'

express = require('express')
resource = require('./resource.controller')
router = express.Router()

router.get '/rangers', (req, res, next) ->
  resource.getRangers (err, rangers) ->
    if err
      next err
    else
      res.json rangers
    return
  return

router.get '/stages', (req, res, next) ->
  resource.getStages (err, stages) ->
    if err
      next err
    else
      res.json stages
    return
  return

module.exports = router
