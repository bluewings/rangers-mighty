'use strict'

passport = require('passport')
NaverStrategy = require('passport-naver').Strategy
resource = require('../../api/resource/resource.controller')

exports.setup = (User, config) ->
  passport.use new NaverStrategy(
    clientID: config.naver.clientID
    clientSecret: config.naver.clientSecret
    callbackURL: config.naver.callbackURL
  , (accessToken, refreshToken, profile, done) ->
    User.findOne
      'naver.id': profile.id
    , (err, user) ->
      return done(err)  if err
      unless user
        resource.getRangers (err, characters) ->
          if err
            done err
          else
            user = new User(
              name: profile.displayName
              email: profile.emails[0].value
              role: 'user'
              username: profile.displayName
              provider: 'naver'
              character: characters[parseInt(Math.random() * characters.length, 10)]
              naver: profile._json
            )
            user.save (err) ->
              done err  if err
              done err, user
      else
        done err, user
      return
    return
  )
  return