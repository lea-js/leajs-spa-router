module.exports = ({init},{
  config: {base: rootBase}
  respond
  fs: {readFile}
  path: {resolve}
}) => init.hookIn ({
  inject
  config: {client, base}
  close
}) =>
  if client
    clientFile = resolve(__dirname,"../lib/client.min.js")
    if client == "inject"
      value = await readFile clientFile, "utf8"
      inject.hookIn ({scripts}) =>
        scripts.push body: value
    else if client
      url = base+"/"+client+".js"
      fullUrl = rootBase+url
      close.hookIn respond.hookIn (req) =>
        req.file = clientFile if req.url == url
      inject.hookIn ({$}) =>
        $("body").append "<script async defer src='#{fullUrl}'></script>"
