'use strict'

express = require('express')
passport = require('passport')
auth = require('../auth.service')

router = express.Router()

passport.serializeUser (user, done) ->
  done null, user
  return

passport.deserializeUser (user, done) ->
  done null, user
  return

authenticate = (req, res, next) ->
  req.session.returnTo = req.headers.referer if req.session and req.headers.referer
  passport.authenticate('naver', (err, user, info) ->
    return next(err) if err
    return res.redirect('/login')  unless user
    req.logIn user, (err) ->
      return next(err) if err
      auth.setTokenCookie req, res
      return
    return
  ) req, res, next
  return

router.get '/', authenticate
router.get '/callback', authenticate

module.exports = router