module.exports = ({init}) => init.hookIn (lea) =>
  {
    config:{spaRouter, index, base:leaBase}, 
    cache: {save}
    path: {resolve, sep}, 
    util: {isArray,isString},
    respond,
    position,
    getRequest
    close: closeLea
  } = lea

  cheerio = require "cheerio"

  hookUp = require "hook-up"
  readConf = require "read-conf"

  rootUrl = "__root"
  htmlDelimiter = "__"

  save["$"] =
    perm: false
    serialize: (val) => val.html()
    deserialize: (val) => cheerio.load(val)

  resolveFolder = (path) =>
    path = resolve(path)
    path += sep unless path.endsWith(sep)
    return path

  spaRouter.htmlDelimiter = htmlDelimiter
  config = spaRouter

  resolveRequest = (request) =>
    respond(request).then (resp) =>
      delete resp.trailers
      await resp.end()
      return resp

  class SpaRouter
    constructor: ->
      hookUp @,
        spread: 2
        actions: ["init","inject","getHtml","processRoutes","close"]
    
    lea: lea
    config: config
    util: resolveFolder: resolveFolder

  closeLea.hookIn => closer?()

  {close: closer} = await readConf 
    name: config.routesFile
    prop: "routes"
    watch: config.watch
    folders: config.routesFolder
    schema: resolve(__dirname, "./routesSchema")
    plugins:
      plugins: config.plugins
      disablePlugins: config.disablePlugins
      paths: [process.cwd(),__dirname]
    assign: config.routes
    base: new SpaRouter
    required: false
    cancel: ({resetAllActions, close}) =>
      await close().catch (e) => console.log e
      resetAllActions()

    cb: (router) =>
      if Object.keys(routes = router.routes).length > 0
        {config, inject, getHtml} = router
        {view:viewId, base} = config
        viewSelector = "#" + viewId

        fullBase = leaBase+base
        router.util.toFullUrl = toFullUrl = (url) => fullBase+url
        router.util.toHtmlUrl = toHtmlUrl = (url) => fullBase+url+htmlDelimiter
        fullRootUrl = toFullUrl(rootUrl)
        rootRoute = 
          isRoot: true
          htmlUrl: toHtmlUrl(rootUrl)
        routes[rootUrl] = rootRoute

        if config.root
          rootRoute.file = config.root
        else
          rootRoute.html = "<html><head><meta charset=\"UTF-8\"></head><body></body></html>"

        await Promise.all router.plugins.map ({plugin}) => plugin(router, lea)
        await router.init()

        {routesMap, _routesMap} = await router.processRoutes 
          routes: routes
          urls: Object.keys(routes)
        defaultRoute = routesMap.get(config.default)

        router.close.hookIn respond.hookIn position.after, (req) =>
          if not req.body? and not req.file?

            url = req.url
            if base
              return unless ~(url.indexOf(base))
              url = url.replace(base,"")

            if not (route = routesMap.get(url))? and not (_route = _routesMap.get(url))?
              if (redirect = config.redirect)
                if not isArray(redirect) or ~redirect.indexOf(url)
                  route = defaultRoute
            if route?
              unless route.isRoot
                {$, dependencies} = await resolveRequest getRequest req.request, fullRootUrl
                {fullUrl} = route
                selector = "#" + fullUrl.replace(/\//g, "\\/")
                if (view = $(viewSelector)).length
                  view.html(route._html).attr("route",fullUrl)
                req.body = $.html()
                req.dependencies = dependencies
                req.encode = route.encode
                req.cache = route.cache

              else
                # get maybe caches content of root file
                {body, dependencies} = await resolveRequest getRequest req.request, route.htmlUrl
                $ = req.$ = cheerio.load body
                req.body = ""
                req.encode = false
                req.dependencies = dependencies
                
                # make sure to always have viewId
                body = $("body")
                unless body.has(viewSelector).length
                  bodyScripts = body.children "script"
                  if bodyScripts.length > 0
                    firstScript = bodyScripts.first()
                    firstScript.before "<div id='#{viewId}'></div>"
                  else
                    body.append "<div id='#{viewId}'></div>"

                
                {push} = Array::
                workers = []
                clientRoutes = {}
                locale = req.locale
                routesMap.forEach (route) =>
                  if not route.isRoot and (not route.locale or route.locale == locale)
                    workers.push(resolveRequest getRequest req.request, route.htmlUrl
                      .then ({dependencies:deps, body}) =>
                        route._html = body
                        if route.inject
                          tmp = html: body
                          push.apply(dependencies,deps) if deps.length > 0
                        else
                          tmp = url: route.htmlUrl
                        tmp.before = route.before if route.before
                        tmp.after = route.after if route.after
                        clientRoutes[route.fullUrl] = tmp
                    )
                
                await Promise.all(workers)
                scripts = [{
                  global:
                    _spa:
                      config: view: viewSelector
                      routes: clientRoutes
                }]
                inject $:$, dependencies:dependencies, scripts: scripts
                .then ({$, scripts}) =>
                  tmp = []
                  heads = ""
                  bodys = ""
                  for scr in scripts
                    if scr.global
                      tmp.push scr.global 
                    if scr.head
                      heads += scr.head
                    if scr.body
                      bodys += scr.body
                  if tmp.length > 0
                    heads = tmp.map (obj) =>
                      Object.keys(obj).map (k) =>
                        "window['#{k}']=" + JSON.stringify(obj[k], (key,val) =>
                          if typeof val == "function"
                            "###"+val.toString()+"###"
                          else
                            val
                        ).replace(/"/g,"'").replace(/'###(.+?)###'/g, (match, func) =>
                          func.replace(/\s*\\n\s*/g,"")
                          .replace(/\\'/g , "'")
                        )

                      .join(";")
                    .join(";") + ";" + heads
                  if heads
                    head = $("head")
                    head.append "<script type='text/javascript'>#{heads}</script>"
                  if bodys
                    body.append "<script type='text/javascript'>#{bodys}</script>"
              
            else if _route
              _route.dependencies = _route.deps?.slice() or []
              {
                route:
                  dependencies: req.dependencies
                  _html: req.body
              } = await getHtml(route: _route, req: req)
              req.encode = false

module.exports.configSchema = require "./configSchema" 