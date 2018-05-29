module.exports = ({init},{
  fs: {readFile}
  path: {extname, resolve}
  Promise
}) => init.hookIn ({
  getHtml
  processRoutes
  position
  config: {
    transform
    transformOptions
    index
  }
}) =>

  jstransformer = null
  parseTransform = (trans) =>
    jstransformer ?= require "jstransformer"
    tmp = require "jstransformer-#{trans}"
    if tmp.outputFormat != "html"
      throw new Error "jstransformer-#{trans} doesn't output html"
    if (input = tmp.inputFormats)
      for ext in input
        break if ext.length < 5
      ext = "html" if ext.length > 4
    else
      ext = "html"
    return [ext, jstransformer(tmp)]

  if transform
    transform = parseTransform(transform)
      
  processRoutes.hookIn position.after, ({urls,routes}) =>
    for url in urls
      route = routes[url]
      if (tmp = route.transform)
        [ext, route.trans] = parseTransform(tmp)
      else if transform
        [ext, route.trans] = transform
      else
        ext = null
      unless (file = route.fullFile)
        file = route.file = route.file or url.replace("/","") or index
        file = resolve route.folder, file
        unless extname(file)
          ext = route.ext ?= ext or "html"
          file += "." + ext
        route.fullFile = file

  {push} = Array::
  getHtml.hookIn ({route}, spaRouter) =>
    if (_html = route.html)
      route._html = _html
    else
      {fullFile: file, trans} = route
      if trans
        read = trans.renderFileAsync(file, transformOptions, {route: route, routes: spaRouter.routes})
      else
        read = readFile file, "utf8"
        .then (result) =>
          body: result, dependencies: [file]
      read
      .catch (e) => 
        return body: ""
      .then ({body, dependencies}) =>
        route._html = body
        if dependencies
          push.apply route.dependencies, dependencies