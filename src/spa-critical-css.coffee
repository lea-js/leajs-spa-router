module.exports = ({
  init
},{
  fs
  path: {resolve}
  respond
}) => init.hookIn ({
  config: {criticalCss}
  inject
  close
}) =>
  if criticalCss
    folder = criticalCss.folder or "app_build/"
    criticalCss.hashed ?= true
    criticalFile = resolve(folder,(criticalCss.critical or "_critical")) + ".css"

    uncritFile = (criticalCss.uncritical or "_uncritical") + ".css"
    _uncriticalFile = uncriticalFile = resolve(folder,uncritFile)

    hashed = criticalCss.hashed or not criticalCss.hashed?
    getCritical = => fs.readFile criticalFile, "utf8"
    getUncritical = =>
      if hashed
        fs.readFile _uncriticalFile, "utf8"
        .then (result) => 
          uncriticalFile = resolve(folder,result)
          uncritFile = "/" + result
      else
        result
    close.hookIn respond.hookIn (req) =>
      req.file = uncriticalFile if req.url == uncritFile
    inject.hookIn ({$,scripts,dependencies}) =>
      Promise.all [getCritical(), getUncritical()]
      .then ([critical, uncritical]) =>
        dependencies.push criticalFile
        dependencies.push _uncriticalFile
        scripts.push head: "window.addEventListener('load',function(){
                var l,d=document;
                l=d.createElement('link');
                l.type='text/css';
                l.rel='stylesheet';
                l.href='#{uncritical}';
                d.head.appendChild(l)
              }, false)".replace(/\n/g,"")
        head = $("head")
        head.remove "link[rel='stylesheet']"
        head.append "<style type='text/css'>#{critical}</style>
          <noscript>
            <link rel='stylesheet' href='#{uncritical}'></link>
          </noscript>"
      .catch (e) => console.log e
