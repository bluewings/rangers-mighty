true
#jslint regexp: true, unparam: true, indent: 4 

#global jQuery: true 
uid = ->
  (parseInt(Math.random() * 900000000 + 100000000, 10)).toString(36).substr 0, 6
getSharedData = (info) ->
  filepath = '/uploads/' + info.namespace + '/'
  metafilePath = path.join(__dirname, '..', 'public', 'uploads', info.namespace, info.workId + '_manifest.json')
  result = false
  if fs.existsSync(metafilePath)
    manifestData = fs.readFileSync(metafilePath, 'utf8')
    try
      manifestData = JSON.parse(manifestData)
      manifestData.workId = info.workId
      manifestData.thumb = filepath + info.workId + '_thumb.png'
      result = manifestData
      result.namespace = info.namespace
      result.sharedTm = info.sharedTm
    catch ignore
      console.log ignore
  
  # skip
  console.log result
  result
checkNamespace = (namespace, callback) ->
  dir = path.join(__dirname, '..', 'public', 'uploads', namespace)
  fs.mkdirSync dir  unless fs.existsSync(dir)
  dir
express = require('express')
router = express.Router()
fs = require('fs')
path = require('path')
exec = require('child_process').exec
gm = require('gm')
SUCCESS = 'success'
ERROR = 'error'
THUMB_SIZE = 200
rootPath = undefined
getNamespaces = undefined
getDemoList = undefined
rootPath = path.join(__dirname, '..', '..')
getDemoList = (namespacePath) ->
  dir = undefined
  demos = []
  demoData = undefined
  i = undefined
  files = undefined
  ignore = undefined
  dir = path.join(__dirname, '..', '..', 'public', 'uploads', namespacePath)
  if fs.existsSync(dir) and fs.statSync(dir).isDirectory()
    files = fs.readdirSync(dir)
    demos = []
    for i of files
      if fs.existsSync(path.join(dir, files[i], 'demo.json'))
        demoData = fs.readFileSync(path.join(dir, files[i], 'demo.json'), 'utf8')
        try
          demoData = JSON.parse(demoData)
          demoData._id = files[i]
          demos.push demoData
  demos

getNamespaces = (req, res) ->
  dir = undefined
  files = undefined
  namespaces = undefined
  subdir = undefined
  demodir = undefined
  i = undefined
  manifest = undefined
  data = undefined
  key = undefined
  ignore = undefined
  dir = path.join(rootPath, 'public', 'app')
  unless fs.existsSync(dir)
    res.status(404).send 'file not found.'
  else
    files = fs.readdirSync(dir)
    namespaces = []
    for i of files
      subDir = path.join(dir, files[i])
      manifest = path.join(dir, files[i], 'manifest.json')
      if fs.statSync(subDir).isDirectory() and fs.existsSync(manifest)
        manifest = fs.readFileSync(manifest, 'utf8')
        try
          data = []
          manifest = JSON.parse(manifest)
          if manifest.data
            for key of manifest.data
              if manifest.data.hasOwnProperty(key)
                manifest.data[key].name = key
                data.push manifest.data[key]
          manifest.path = files[i]
          manifest.data = data
          manifest.demoList = getDemoList(manifest.path)
          namespaces.push manifest  if manifest.name
    res.jsonp namespaces
  return

upload = (req, res) ->
  src = undefined
  dst = undefined
  srcFolder = undefined
  dstFolder = undefined
  srcPath = undefined
  dstPath = undefined
  dstFilename = undefined
  res.status(500).send 'cannot find uploaded file.'  unless req.files.file
  srcFolder = path.join(__dirname, '..', '..', 'public', 'uploads', '.tmp')
  dstFolder = path.join(__dirname, '..', '..', 'public', 'uploads', '_tmp')
  dstFilename = uid() + '.' + req.files.file.extension
  srcPath = path.join(srcFolder, req.files.file.name)
  dstPath = path.join(dstFolder, dstFilename)
  fs.mkdir dstFolder, (err) ->
    src = fs.createReadStream(srcPath)
    dst = fs.createWriteStream(dstPath)
    src.pipe dst
    src.on 'end', ->
      fs.unlink srcPath
      res.jsonp
        filename: dstFilename
        url: '/uploads/_tmp/' + dstFilename

      return

    src.on 'error', (err) ->
      fs.unlink srcPath
      res.status(500).send err
      return

    return

  return


#getNamespaces();
router.get '/namespaces', getNamespaces
router.post '/upload', upload
router['delete'] '/:path/:demoId', (req, res) ->
  targetDir = undefined
  files = undefined
  i = undefined
  targetDir = path.join(__dirname, '..', '..', 'public', 'uploads', req.params.path, req.params.demoId)
  res.status(500).send 'target not found.'  unless fs.existsSync(targetDir)
  files = fs.readdirSync(targetDir)
  for i of files
    fs.unlink path.join(targetDir, files[i])  if files.hasOwnProperty(i)
  setTimeout (->
    fs.rmdirSync targetDir
    res.jsonp {}
    return
  ), 100
  return

router.put '/:path/:demoId', (req, res) ->
  dstFolder = undefined
  key = undefined
  filename = undefined
  tmpFolder = undefined
  resultFolder = undefined
  tmpFolder = path.join(__dirname, '..', '..', 'public', 'uploads', '_tmp')
  resultFolder = path.join(__dirname, '..', '..', 'public', 'uploads', req.params.path, req.params.demoId)
  res.status(500).send 'data not found.'  unless req.body.data
  res.status(500).send 'data folder not found.'  unless fs.existsSync(resultFolder)
  for key of req.body.data
    if req.body.data.hasOwnProperty(key) and req.body.data[key]
      filename = req.body.data[key]
      if fs.existsSync(path.join(tmpFolder, filename))
        ((filename) ->
          srcPath = undefined
          srcPath = path.join(tmpFolder, filename)
          src = fs.createReadStream(srcPath)
          src.pipe fs.createWriteStream(path.join(resultFolder, filename))
          src.on 'end', ->
            fs.unlink srcPath
            return

          return
        ) filename
  fs.writeFile path.join(resultFolder, 'demo.json'), JSON.stringify(req.body.data), (err) ->
    res.jsonp demoId: req.params.demoId
    return

  return

router.post '/:path', (req, res) ->
  dstFolder = undefined
  demoId = undefined
  key = undefined
  filename = undefined
  tmpFolder = undefined
  parentFolder = undefined
  resultFolder = undefined
  demoId = uid()
  tmpFolder = path.join(__dirname, '..', '..', 'public', 'uploads', '_tmp')
  parentFolder = path.join(__dirname, '..', '..', 'public', 'uploads', req.params.path)
  resultFolder = path.join(parentFolder, demoId)
  res.status(500).send 'data not found.'  unless req.body.data
  fs.mkdirSync parentFolder  unless fs.existsSync(parentFolder)
  res.status(500).send 'dup err. try again.'  if fs.existsSync(resultFolder)
  fs.mkdir resultFolder, (err) ->
    res.status(500).send 'failed to create result folder.'  if err
    for key of req.body.data
      if req.body.data.hasOwnProperty(key) and req.body.data[key]
        filename = req.body.data[key]
        if fs.existsSync(path.join(tmpFolder, filename))
          ((filename) ->
            srcPath = undefined
            srcPath = path.join(tmpFolder, filename)
            src = fs.createReadStream(srcPath)
            src.pipe fs.createWriteStream(path.join(resultFolder, filename))
            src.on 'end', ->
              fs.unlink srcPath
              return

            return
          ) filename
    fs.writeFile path.join(resultFolder, 'demo.json'), JSON.stringify(req.body.data), (err) ->
      res.jsonp demoId: demoId
      return

    return

  return

router.get '/:namespace/work', (req, res) ->
  dir = undefined
  files = undefined
  filepath = undefined
  matches = undefined
  i = undefined
  works = []
  filePath = '/uploads/' + req.params.namespace + '/'
  manifestData = undefined
  dir = path.join(__dirname, '..', 'public', 'uploads', req.params.namespace)
  checkNamespace dir  unless fs.existsSync(dir)
  if fs.existsSync(dir) and fs.statSync(dir).isDirectory()
    files = fs.readdirSync(dir)
    for i of files
      if files[i] is 'shared.json'
        shared = undefined
        i = undefined
        filepath = path.join(dir, files[i])
        shared = fs.readFileSync(filepath, 'utf8')
        try
          shared = JSON.parse(shared)
        catch err
          shared = []
        sharedList = []
        i = 0
        while i < shared.length
          each = getSharedData(shared[i])
          sharedList.push each  if each
          i++
        console.log sharedList
      if files.hasOwnProperty(i)
        filepath = path.join(dir, files[i])
        matches = filepath.match(/([a-zA-Z0-9]+)\_manifest.json$/)
        if matches and not fs.statSync(filepath).isDirectory()
          manifestData = fs.readFileSync(filepath, 'utf8')
          try
            manifestData = JSON.parse(manifestData)
            manifestData.workId = matches[1]
            manifestData.thumb = filePath + matches[1] + '_thumb.png'
            works.push manifestData
    
    # skip
    res.jsonp
      status: SUCCESS
      data:
        works: works
        shared: sharedList

  else
    res.jsonp
      status: ERROR
      message: 'namespace not found.'

  return

router.get '/:namespace/work/:workId', (req, res) ->
  manifestFile = path.join(__dirname, '..', 'public', 'uploads', req.params.namespace, req.params.workId + '_manifest.json')
  manifestData = {}
  if fs.existsSync(manifestFile)
    manifestData = fs.readFileSync(manifestFile, 'utf8')
    try
      manifestData = JSON.parse(manifestData)
      manifestData.workId = req.params.workId
      if req.params.namespace isnt req.query.requestedBy
        dir = checkNamespace(req.query.requestedBy)
        sharedFile = path.join(dir, 'shared.json')
        shared = fs.existsSync(sharedFile)
        i = undefined
        if shared
          shared = fs.readFileSync(sharedFile, 'utf8')
          try
            shared = JSON.parse(shared)
          catch err
            shared = []
        else
          shared = []
        found = false
        i = 0
        while i < shared.length
          found = true  if shared[i].namespace is req.params.namespace and shared[i].workId is req.params.workId
          i++
        if found is false
          shared.push
            namespace: req.params.namespace
            workId: req.params.workId
            sharedTm: (new Date()).toISOString()

          fs.writeFile sharedFile, JSON.stringify(shared), (err) ->
            res.jsonp
              status: SUCCESS
              data: manifestData

            return

        else
          res.jsonp
            status: SUCCESS
            data: manifestData

        console.log shared
      
      #
      else
        res.jsonp
          status: SUCCESS
          data: manifestData

    catch err
      console.log err
      res.jsonp
        status: ERROR
        message: 'invalid manifest file.'

  else
    res.jsonp
      status: ERROR
      message: 'manifest file not found.'

  return

router.post '/:namespace/work/:workId', (req, res) ->
  jsonFile = path.join(__dirname, '..', 'public', 'uploads', req.params.namespace, req.params.workId + '.json')
  pngFile = path.join(__dirname, '..', 'public', 'uploads', req.params.namespace, req.params.workId + '.png')
  manifestFile = path.join(__dirname, '..', 'public', 'uploads', req.params.namespace, req.params.workId + '_manifest.json')
  thumbFile = path.join(__dirname, '..', 'public', 'uploads', req.params.namespace, req.params.workId + '_thumb.png')
  now = (new Date()).toISOString()
  manifestData = {}
  gmInst = undefined
  if fs.existsSync(jsonFile) and fs.existsSync(pngFile)
    unless fs.existsSync(manifestFile)
      manifestData =
        name: req.body.name or req.body.fileName
        fileName: req.params.workId + '.psd'
        fileSize: req.body.fileSize
        width: req.body.width
        height: req.body.height
        created: now
        lastModified: now

      
      # generate thumbnail
      gmInst = gm(path.join(pngFile)).autoOrient()
      gmInst.size (err, source) ->
        width = null
        height = null
        if err
          res.jsonp
            status: ERROR
            message: err

        else
          if source.width < source.height
            width = THUMB_SIZE
          else
            height = THUMB_SIZE
          gmInst.resize(width, height).write thumbFile, (err) ->
            
            # write manifest
            fs.writeFile manifestFile, JSON.stringify(manifestData), (err) ->
              res.jsonp
                status: SUCCESS
                data:
                  workId: req.params.workId

              return

            return

        return

    else
      res.jsonp
        status: ERROR
        message: 'already exists.'

  else
    res.jsonp
      status: ERROR
      message: 'work file not found.'

  return

router.put '/:namespace/work/:workId', (req, res) ->
  manifestFile = path.join(__dirname, '..', 'public', 'uploads', req.params.namespace, req.params.workId + '_manifest.json')
  manifestData = {}
  entries = [
    'name'
    'fileName'
    'fileSize'
    'width'
    'height'
  ]
  now = (new Date()).toISOString()
  i = undefined
  if not req.body.modifiedBy or not req.body.snapshot
    res.jsonp
      status: ERROR
      message: 'invalid request : modifiedBy & snapshot required.'

  else if fs.existsSync(manifestFile)
    manifestData = fs.readFileSync(manifestFile, 'utf8')
    try
      manifestData = JSON.parse(manifestData)
      i = 0
      while i < entries.length
        manifestData[entries[i]] = req.body.snapshot[entries[i]]  if req.body.snapshot[entries[i]] and req.body.snapshot[entries[i]] isnt manifestData[entries[i]]
        i++
      manifestData.revisions = []  unless manifestData.revisions
      req.body.snapshot.modifiedBy = req.body.modifiedBy
      req.body.snapshot.modified = now
      manifestData.lastModified = now
      manifestData.revisions.push req.body.snapshot
      fs.writeFile manifestFile, JSON.stringify(manifestData), (err) ->
        res.jsonp
          status: SUCCESS
          data:
            workId: req.params.workId

        return

    catch err
      res.jsonp
        status: ERROR
        message: 'invalid manifest file.'

  else
    res.jsonp
      status: ERROR
      message: 'manifest file not found.'

  return

router['delete'] '/:namespace/work/:workId', (req, res) ->
  dir = undefined
  files = undefined
  i = undefined
  dir = path.join(__dirname, '..', 'public', 'uploads', req.params.namespace)
  if fs.existsSync(dir) and fs.statSync(dir).isDirectory()
    files = fs.readdirSync(dir)
    for i of files
      fs.unlink path.join(dir, files[i])  if files[i].match(req.params.workId)  if files.hasOwnProperty(i)
    res.jsonp
      status: SUCCESS
      data: {}

  else
    res.jsonp
      status: ERROR
      message: 'namespace not found.'

  return

router.post '/:namespace/upload', (req, res) ->
  src = undefined
  dst = undefined
  srcFolder = undefined
  dstFolder = undefined
  srcPath = undefined
  dstPath = undefined
  libPath = path.join(__dirname, '..', 'lib', 'markupguide.jar')
  workId = uid()
  srcFolder = path.join(__dirname, '..', '_tmp', 'uploads')
  dstFolder = path.join(__dirname, '..', 'public', 'uploads', req.params.namespace)
  srcPath = path.join(srcFolder, req.files.file.name)
  dstPath = path.join(dstFolder, workId + '.psd')
  fs.mkdir dstFolder, (err) ->
    src = fs.createReadStream(srcPath)
    dst = fs.createWriteStream(dstPath)
    src.pipe dst
    src.on 'end', ->
      cmd = 'java -jar ' + libPath + ' ' + dstPath
      fs.unlink srcPath
      exec cmd, (err, stdout, stderr) ->
        if err
          res.jsonp
            status: ERROR
            message: err

        else
          setTimeout (->
            gmInst = gm(path.join(path.join(dstFolder, workId + '.png'))).autoOrient()
            gmInst.size (err, source) ->
              res.jsonp
                status: SUCCESS
                data:
                  workId: workId
                  name: req.files.file.originalname.replace(/\.psd$/, '')
                  fileName: req.files.file.originalname
                  fileSize: req.files.file.size
                  filePath: '/uploads/' + req.params.namespace + '/'
                  mimetype: req.files.file.mimetype
                  width: source.width
                  height: source.height

              return

            return
          ), 300
        return

      return

    src.on 'error', (err) ->
      fs.unlink srcPath
      res.jsonp
        status: ERROR
        message: err

      return

    return

  return

module.exports = router
