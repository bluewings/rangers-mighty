'use strict'

fs = require('fs')
path = require('path')
mkdirp = require('mkdirp')

walkSync = (dir, filelist) ->
  unless dir
    dir = __dirname
  if dir.search(/\/$/) is -1
    dir = dir + '/'
  dir = path.join(dir, '')
  files = fs.readdirSync(dir)
  filelist = filelist or []
  files.forEach (file) ->
    if fs.statSync(dir + file).isDirectory()
      filelist = walkSync(dir + file + '/', filelist)
    else
      filelist.push dir + file
    return
  filelist

getRangerImageList = (srcDir) ->
  rangerImageList = []
  fileList = walkSync(srcDir)
  for file in fileList
    if file.search(/\/u[0-9]{1,3}[a-z]{0,1}\-/) isnt -1 and file.search(/\-thum-140\.png/) isnt -1
      rangerImageList.push file
  rangerImageList

getStageImageList = (srcDir) ->
  stageImageList = []
  fileList = walkSync(srcDir)
  for file in fileList
    if file.search(/bg.png$/) isnt -1 and file.search(/battle/) isnt -1
      stageImageList.push file
  stageImageList

copyRangerImageList = (dstDir, rangerImageList, callback, count = 0) ->
  if rangerImageList and rangerImageList.length > 0
    mkdirp dstDir + '/rangers', (err) ->
      count++
      image = rangerImageList.pop()
      source = image
      filename = image.split('/').pop()
      target = path.join(dstDir, 'rangers', filename)
      read = fs.createReadStream(source)
      write = fs.createWriteStream(target)
      write.on 'finish', ->
        console.log "'#{filename}' copied."
        copyRangerImageList(dstDir, rangerImageList, callback, count)
        return
      read.pipe write
  else
    console.log "total #{count} ranger files were copied."
    callback() if callback

copyStageImageList = (dstDir, stageImageList, callback, count = 0) ->
  if stageImageList and stageImageList.length > 0
    mkdirp dstDir + '/stages', (err) ->
      count++
      image = stageImageList.pop()
      source = image
      chunk = image.split('/')
      filename = chunk.pop()
      filename = chunk.pop() + '-' + filename
      target = path.join(dstDir, 'stages', filename)
      read = fs.createReadStream(source)
      write = fs.createWriteStream(target)
      write.on 'finish', ->
        console.log "'#{filename}' copied."
        copyStageImageList(dstDir, stageImageList, callback, count)
        return
      read.pipe write
  else
    console.log "total #{count} stage files were copied."
    callback() if callback

srcDir = '/Users/naver/Desktop/윤재/res2'
dstDir = path.join(__dirname, '..', 'public/assets')

rangerImageList = getRangerImageList srcDir
copyRangerImageList dstDir, rangerImageList, ->

  stageImageList = getStageImageList srcDir
  copyStageImageList dstDir, stageImageList