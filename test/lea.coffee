{test, prepare, Promise, getTestID} = require "snapy"
try
  Lea = require "leajs-server/src/lea"
catch
  Lea = require "leajs-server"
http = require "http"
{writeFile, unlink} = require "fs-extra"

require "!./src/plugin"

port = => 8081 + getTestID()

request = (path = "/", headers = {}) =>
  filter: "headers,statusCode,-headers.date,-headers.last-modified,body"
  stream: "":"body"
  plain: true
  promise: new Promise (resolve, reject) =>
    http.get Object.assign({
      hostname: "localhost"
      port: port()
      agent: false
      headers: headers
      }, {path: path}), resolve
    .on "error", reject

prepare (state, cleanUp) =>
  lea = await Lea
    config: Object.assign (state or {}), {
      verbose: 0
      listen:
        port:port()
      
    }
  cleanUp => lea.close()

test {spaRouter: {client: "router", polyfills:{}}}, (snap) =>
  # index
  snap request("/")
  # route
  snap request("/route")
  # plain route
  snap request("/route__")
  # index on invalid route
  snap request("/invalid")
getLocale = () =>
  available:["de","en"]
  query: "loc"
test {locale: getLocale(),spaRouter: {client: "router", polyfills:{}, folder: ((loc) => "app/#{loc}"), routes: "/locale": null}}, (snap) =>
  # locale de
  snap request("/locale__?loc=de")
  # locale en
  snap request("/locale__?loc=en")

test {locale: getLocale(),spaRouter: {client: "router", polyfills:{}, routes: "/de": locale: en: "/en"}}, (snap) =>
  snap request("/de__?loc=en")
  snap request("/de__?loc=de")
  snap request("/en__?loc=en")
  snap request("/en__?loc=de")

test {locale: getLocale(),spaRouter: {client: "router", polyfills:{}, routes: "/de": locale: en: "/en"}}, (snap) =>
  snap request("/de__?loc=en")
  snap request("/de__?loc=de")
  snap request("/en__?loc=en")
  snap request("/en__?loc=de")

test {spaRouter: {client: "router"}}, (snap) =>
  # inject polyfill check
  snap request("/")
  # deliver polyfill
  snap request("/p/p.js")

test {spaRouter: {client: "router", polyfills:{},routes: {"/": transform:"pug"}}}, (snap) =>
  # get index.pug
  snap request("/")

test {webpack:{manifest:true,chunkManifest:true},spaRouter: {client: "router"}}, (snap) =>
  # get manifest
  snap request("/")

test {spaRouter: {client: "router",criticalCss:true}}, (snap) =>
  # get critical css
  snap request("/")
  .then =>
    # get uncritical css
    snap request("/0e323e13e161be87953bbf8bb63a27db0661e4c2.css")