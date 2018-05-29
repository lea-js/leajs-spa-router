module.exports = ({init}) => init.hookIn ({
  config: {
    folder
    inject
    htmlDelimiter
  }
  processRoutes
  position
  util: {
    resolveFolder
    toFullUrl
    toHtmlUrl
  }}) =>
  folder = resolveFolder folder
  processRoutes.hookIn position.init, ({urls, routes}) =>
    for url in urls
      routes[url] ?= {}

  processRoutes.hookIn ({urls,routes}) =>
    for url in urls
      route = routes[url]
      route.inject ?= inject
      if (tmp = route.folder)
        tmp = resolveFolder folder, tmp
      else
        tmp = folder
      route.folder = tmp
      route.fullUrl = toFullUrl(url)
      route.htmlUrl = toHtmlUrl(url)

  processRoutes.hookIn position.end, (state) =>
    routesMap = state.routesMap = new Map()
    _routesMap = state._routesMap = new Map()
    {routes} = state
    for url in state.urls
      routesMap.set url, (tmp = routes[url])
      _routesMap.set url+htmlDelimiter, tmp

    