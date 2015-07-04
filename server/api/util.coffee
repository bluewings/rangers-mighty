true
#jslint unparam: true, regexp: true, indent: 4 
unescapeHTML = (str) ->
  (if str then str.replace(/\&lt;/g, '<').replace(/\&gt;/g, '>').replace(/\&quot;/g, '"').replace(/\&#039;/g, '\'').replace(/\&amp;/g, '&') else '')
sendRequest = (requestUrl, callback) ->
  urlInfo = require('url').parse(requestUrl)
  httpReq = undefined
  httpReq = http.request(
    host: urlInfo.hostname
    port: parseInt(urlInfo.port, 10)
    path: urlInfo.path
    method: 'GET'
    headers:
      Host: urlInfo.hostname
      Connection: urlInfo.hostname
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36'
  )
  httpReq.on 'response', (response) ->
    data = []
    response.setEncoding 'utf8'
    response.on 'data', (chunk) ->
      data.push chunk.toString('utf8')
      return

    response.on 'end', ->
      callback null, data.join('')
      return

    return

  httpReq.on 'error', (err) ->
    callback err, null
    return

  httpReq.end()
  return
isArray = (value) ->
  return true  if Object::toString.call(value) is '[object Array]'
  false
getGroupList = (callback) ->
  sendRequest 'http://cl.news.naver.com/api/group/list.nhn', (err, data) ->
    inx = undefined
    jnx = undefined
    knx = undefined
    try
      data = JSON.parse(data)
    data = []  unless isArray(data)
    inx = 0
    while inx < data.length
      jnx = 0
      while jnx < data[inx].clusterList.length
        knx = 0
        while knx < data[inx].clusterList[jnx].articleList.length
          data[inx].clusterList[jnx].articleList[knx].title = unescapeHTML(data[inx].clusterList[jnx].articleList[knx].title)
          knx++
        data[inx].clusterList[jnx].topArticle.title = unescapeHTML(data[inx].clusterList[jnx].topArticle.title)
        jnx++
      inx++
    callback err, data  if callback
    return

  return
getArticle = (officeId, articleId, callback) ->
  sendRequest 'http://api.news.naver.com/main/export/v2/news/read.nhn?sid=107&group=SEC&oid=' + officeId + '&aid=' + articleId, (err, data) ->
    try
      xml2js.parseString data, (err, result) ->
        key = undefined
        subKey = undefined
        tmp = undefined
        result = result.message.result[0].article[0]
        for key of result
          if result.hasOwnProperty(key)
            if key is 'sections' and result.sections[0].section
              tmp = []
              for subKey of result.sections[0].section[0]
                if result.sections[0].section[0].hasOwnProperty(subKey)
                  tmp.push
                    id: result.sections[0].section[0][subKey][0].id[0]
                    name: result.sections[0].section[0][subKey][0].name[0]

              result.sections = tmp
            else
              result[key] = result[key][0]
        result.title = unescapeHTML(result.title)
        callback null, result  if callback
        return

    catch setDefault
      callback null, {}  if callback
    return

  return
async = require('async')
http = require('http')
url = require('url')
xml2js = require('xml2js')
module.exports =
  getGroupList: getGroupList
  getArticle: getArticle
