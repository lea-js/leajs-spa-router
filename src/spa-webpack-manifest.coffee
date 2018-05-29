module.exports = ({
  init
},{
  path: {resolve}
  config: {webpack}
  fs: {readJson}
  Promise
}) => init.hookIn ({
  inject
  watcher
}) =>
  {
    manifest: manifestFile
    chunkManifest: chunkManifestFile
    output
    mount
    config:configFile
    folder
  } = webpack
  if manifestFile or chunkManifestFile
    if not mount? or not output?
      try
        readConf = require "read-conf"
        {
          config:{
            output:{
              publicPath, 
              path
            }
          }
        } = await readConf
          name: configFile or "webpack.config"
          folders: folder or ["./build","./"]
        mount ?= publicPath
        output ?= paths
    mount ?= ""
    output ?= "./app_build"
    if manifestFile == true
      manifestFile = "manifest.json"
    manifestFile = resolve(output, manifestFile) if manifestFile
    if chunkManifestFile == true
      chunkManifestFile = "chunk-manifest.json"
    chunkManifestFile = resolve(output, chunkManifestFile) if chunkManifestFile
    getManifestFile = =>
      if manifestFile
        readJson(manifestFile)
      else
        Promise.resolve()
    getChunkManifestFile = =>
      if chunkManifestFile
        readJson(chunkManifestFile)
      else
        Promise.resolve()
    inject.hookIn ({$,scripts,dependencies}) =>
      Promise.all [getManifestFile(),getChunkManifestFile()]
      .then ([manifest, chunkManifest]) =>
        lookUp = {}

        if chunkManifest
          dependencies.push chunkManifestFile
          for k,v of chunkManifest
            lookUp[v] = true
          scripts.push global: webpackManifest: chunkManifest  

        if manifest
          dependencies.push manifestFile
          head = $("head")
          body = $("body")
          for k,v of manifest
            if not lookUp[v]
              k = mount + k
              v = mount + v
              switch k.slice(-3)
                when ".js"
                  if (selected = $("script[src='#{k}']")).length > 0
                    selected.attr "src", v
                  else
                    body.append "<script src='#{v}' async defer></script>"
                when "css"
                  if (selected = $("link[href='#{k}']")).length > 0
                    selected.attr "href", v
                  else
                    head.append "<link rel='stylesheet' href='#{v}'></link>"
