module.exports = ({init, position, util:{resolveFolder}},{
  config: {locale, base: leaBase}
  util: {isFunction}
  path: {extname, resolve}
  respond
  position: position2
}) =>
  if locale? and ({available} = locale)?
    defaultLoc = available[0]
    gotParsed = false
    parseLoc = (fn,cb) =>
      if fn? and isFunction(fn)
        tmp = {}
        if cb
          for loc in available
            tmp[loc] = cb(fn(loc))
        else
          for loc in available
            tmp[loc] = fn(loc)
        gotParsed = true
        return [tmp[defaultLoc],tmp]
    _folders = null
    init.hookIn position.before, ({config}) =>
      if (parsed = parseLoc(config.folder, resolveFolder))?
        [config.folder, _folders] = parsed
    init.hookIn ({
      processRoutes
      getHtml
      position
      config: {base}
      close
    }) =>
      urlLookUp = {}
      _urlLookUp = {}
      base ?= ""
      processRoutes.hookIn position.before, ({urls, routes}) =>
        addUrls = []
        for url in urls
          route = routes[url]
          if (parsed = parseLoc(route.folder, resolveFolder))?
            [route.folder, folders] = parsed
          else if not route.folder
            folders = _folders
          if (parsed = parseLoc(route.file))?
            [route.file, files] = parsed
          else
            file = null
          if (locLookUp = route.locale)?
            route.locale = defaultLoc
            urlLookUp[url] = locLookUp
            _urlLookUp[url+"__"] = locLookUp
            locLookUp[defaultLoc] = url
            for loc,newUrl of locLookUp
              addUrls.push newUrl
              newRoute = {}
              newRoute.file = files[loc] if files?
              newRoute.folder = folders[loc] if folders?
              urlLookUp[newUrl] = newlocLookUp = Object.assign {}, locLookUp
              _urlLookUp[newUrl+"__"] = newlocLookUp
              delete newlocLookUp[loc]
              routes[newUrl] = Object.assign newRoute, route, locale: loc
            delete locLookUp[defaultLoc]
            
          else
            route._folders = folders if folders
            route._files = files if files
        Array::push.apply(urls, addUrls)
        if Object.keys(urlLookUp).length > 0
          close.hookIn respond.hookIn position2.before-1, (req) =>
            url = req.url
            if base
              return unless ~(url.indexOf(base))
              url = url.replace(base,"")
            if (redirect = urlLookUp[url])?
              if (redirect = redirect[req.locale])?
                req.url = tmp = base + redirect
                req.head.contentLocation = leaBase + tmp

            else if (redirect = _urlLookUp[url])?
              if (redirect = redirect[req.locale])?
                req.url = tmp = base + redirect + "__"
                req.head.contentLocation = leaBase + tmp

      processRoutes.hookIn position.after+1, ({urls, routes}) =>
        if gotParsed
          for url in urls
            route = routes[url]
            if (files = route._files)
              folders = route._folders
              routeFolder = route.folder
              for loc,file of files
                folder = routeFolder or folders?[loc] or 
                file = resolve(folder, file)
                file += "." + route.ext unless extname(file)
                files[loc] = file
            else if (folders = route._folders)
              routeFile = route.file
              files = route._files = {}
              for loc, folder of folders
                file = resolve(folder, routeFile)
                file += "." + route.ext unless extname(file)
                files[loc] = file
              delete route._folders
          getHtml.hookIn position.before, ({route, req: {locale: loc}}) =>
            route.fullFile = file if (file = route._files) and (file = file[loc])
                
                