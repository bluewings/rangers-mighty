true
#jslint unparam: true, regexp: true, indent: 4 
express = require('express')
router = express.Router()
http = require('http')
url = require('url')
router.get '/:imgPath', (req, res) ->
  urlParts = undefined
  options = undefined
  callback = undefined
  urlParts = url.parse(req.params.imgPath, true)
  options =
    host: urlParts.hostname
    path: urlParts.pathname

  callback = (response) ->
    if response.statusCode is 200
      res.writeHead 200,
        'Content-Type': response.headers['content-type']

      response.pipe res
    else
      res.writeHead response.statusCode
      res.end()
    return

  http.request(options, callback).end()
  return

module.exports = router
