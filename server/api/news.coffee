true
#jslint unparam: true, regexp: true, indent: 2 
express = require('express')
router = express.Router()
util = require('./util')
router.get '/group', (req, res) ->
  util.getGroupList (err, data) ->
    res.jsonp data
    return

  return

router.get '/article/:officeId/:articleId', (req, res) ->
  util.getArticle req.params.officeId, req.params.articleId, (err, data) ->
    data.contents = data.content  if data.content
    res.jsonp data
    return

  return

module.exports = router
