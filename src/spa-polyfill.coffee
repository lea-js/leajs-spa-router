module.exports = ({init},{
  respond
  config: {base}
  path: {resolve}
  util: {isString}
}) => init.hookIn ({
  inject
  close
  config: {polyfills, base:spaBase}
}) =>
  if (names = Object.keys(polyfills)).length > 0
    script = "var d=document,h=d.head,c=d.createElement.bind(d),a=h.appendChild.bind(h),s;"
    for name in names
      polyfill = polyfills[name]
      check = polyfill.check or polyfill
      url = spaBase + (polyfill.url or name)
      if (file = polyfill.file)?
        file = resolve(file)
        close.hookIn respond.hookIn ((file,url,req) =>
          req.file = file if req.url == url
        ).bind(null, file, url)
      script += "if(#{polyfill.check}){s=c('script');s.src='#{base+url}';a(s)}"
    inject.hookIn ({scripts}) =>
      scripts.push head: script