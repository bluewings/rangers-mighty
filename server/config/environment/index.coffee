'use strict'

_ = require('lodash')
path = require('path')

# All configurations will extend these options
# ============================================
all =
  env: process.env.NODE_ENV

  # Root path of server
  root: path.normalize(__dirname + '/../../..')

  # Server port
  port: process.env.PORT or 7000

  # Should we populate the DB with sample data?
  seedDB: false

  # Secret for session, you will want to change this and make it an environment variable
  secrets:
    session: 'rangers-mighty'

  # List of user roles
  userRoles: [
    'guest'
    'user'
    'admin'
  ]

  # MongoDB connection options
  mongo:
    options:
      db:
        safe: true

  naver:
    clientID: process.env.NAVER_ID or '6tyrMmP8dfHCtDLwPVzU'
    clientSecret: process.env.NAVER_SECRET or '0UEj2Ayfv0'
    callbackURL: (process.env.DOMAIN or '') + '/auth/naver/callback'

  facebook:
    clientID: process.env.FACEBOOK_ID or '1489164491367703'
    clientSecret: process.env.FACEBOOK_SECRET or 'd418b54093a3a6dbf06e022db3f95dd9'
    callbackURL: (process.env.DOMAIN or '') + '/auth/facebook/callback'

  google:
    clientID: process.env.GOOGLE_ID or '954146773751-0cgq07ahl6aomtq7kcf5iba5qhv7inuk.apps.googleusercontent.com'
    clientSecret: process.env.GOOGLE_SECRET or 'GqKWTHxq582627LCLH7H_A6Q'
    callbackURL: (process.env.DOMAIN or '') + '/auth/google/callback'

# Export the config object based on the NODE_ENV
# ==============================================
# module.exports = _.merge(all, require('./' + process.env.NODE_ENV + '.js') or {})
module.exports = _.merge(all, require('./' + process.env.NODE_ENV) or {})
