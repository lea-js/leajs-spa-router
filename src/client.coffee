isString = (s) -> typeof s == "string" or s instanceof String 

# config and defaults
config = routes = activeClass = activeAttribute = null


# "globals"
_lastFrag =
_currentFrag =
_currentRoute =
_viewEl =
_viewComment =
_viewParent = null
doc = document
body = doc.body
docEl = doc.documentElement
win = window
getScrollPos = ->
  top: win.pageYOffset or docEl.scrollTop or body.scrollTop
  left: win.pageXOffset or docEl.scrollLeft or body.scrollLeft

createContainer = (content) -> 
  el = doc.createElement "div"
  if isString(content)
    el.innerHTML = content
  else if Array.isArray(content)
    for ele in content
      el.appendChild(ele)
  else if content instanceof HTMLElement
    el.appendChild(content)
  return el

getFragment = -> decodeURI(location.pathname)

fragToRoute = (frag, oldFrag) ->
  frag ?= getFragment()
  if (route = routes[frag])
    (route.before?(frag, oldFrag) or Promise.resolve())
    .then ->
      unless route._el?
        if route.html
          return route.html
        else if (gen = route.gen)?
          return gen(frag, route)
        else if (url = route.url)?
          return new Promise (resolve, reject) ->
            xmlHttp = new XMLHttpRequest()
            xmlHttp.onreadystatechange = ->
              if xmlHttp.readyState == 4
                if xmlHttp.status == 200
                  resolve(xmlHttp.responseText)
                else
                  reject()
            xmlHttp.open "GET", url, true
            xmlHttp.send()
      return null
    .then (content) ->
      route._el = createContainer(content) if content 
      return route
  else
    throw new Error "Route #{frag} not found"

loadRoute = (route, frag) ->
  if route?
    _viewParent.replaceChild(_viewComment,_viewEl)
    if (el = _currentRoute?._el)?
      while child = _viewEl.firstChild
        el.appendChild(child)
    else
      _viewEl.innerHTML = ""
    el = route._el
    while child = el.firstChild
      _viewEl.appendChild(child)
    _viewParent.replaceChild(_viewEl,_viewComment)
    _currentRoute = route
    _lastFrag = _currentFrag
    _currentFrag = frag
    return route.after?(frag)

setActive = (frag = _currentFrag, oldFrag = _lastFrag) ->
  if oldFrag
    el = doc.querySelector("[#{activeAttribute}='#{oldFrag}']")
    if el?
      el.className = el.className.replace new RegExp("(?:^|\\s)#{activeClass}(?!\\S)","g"), ""
  el = doc.querySelector("[#{activeAttribute}='#{frag}']")
  el?.className += " #{activeClass}"


open = (frag, isBack) ->
  if frag != (oldFrag = _currentFrag)
    Promise.resolve()
    .then -> config.before?(frag, oldFrag)
    .then -> fragToRoute(frag, oldFrag)
    .then (route) ->
      _currentRoute._scroll ?= []
      _currentRoute._scroll.push getScrollPos()
      loadRoute(route, frag)
    .then ->
      unless isBack
        history.pushState(null, null, frag)
      if (isBack and s = _currentRoute._scroll?.pop())?
        win.scrollTo(s.left,s.top)
      else
        win.scrollTo(0,0)
      setTimeout setActive, 0
    .then -> config.after?(frag)
    .catch (e) ->
      throw e
  else
    return Promise.resolve()
      

back = ->
  if _lastFrag
    open(_lastFrag,true)
    .then ->
      history.replaceState(null, null, _currentFrag)


startup = ->
  setTimeout (->
    {config, routes} = win._spa
    activeClass = config.activeClass or "active"
    activeAttribute = config.activeAttribute or "route"
    _viewEl = doc.querySelector config.view
    _viewComment = doc.createComment("#view")
    _viewParent = _viewEl.parentElement
    deliveredRoute = _viewEl.getAttribute("route")
    _viewEl.removeAttribute("route")

    if (_currentRoute = routes[deliveredRoute])?
      _currentRoute._el = createContainer()
    if deliveredRoute != (current = getFragment())
      open(current)
    else
      _currentFrag = current
      setTimeout setActive, 66
    win.addEventListener "popstate", (e) ->
      frag = getFragment()
      if routes[frag]?
        open(frag, true)
        return null

    doc.addEventListener "click", (e) ->
      el = e.target
      while el? and not (frag = el.pathname)?
        el = el.parentElement
      if frag and frag == el.getAttribute("href") and routes[frag]?
        e.preventDefault()
        open(frag)
  ), 0

if doc.readyState != "loading"
  startup()
else
  doc.addEventListener "DOMContentLoaded", startup

module?.exports =
  open: open
  back: back