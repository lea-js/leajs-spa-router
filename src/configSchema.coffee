isProd = process.env?.NODE_ENV == "production"

module.exports =
  
  spaRouter: 
    type: Object
    default: {}
    desc: "Configuration of spa router"

  spaRouter$base: 
    type: String
    default: ""
    desc: "Namespace for the router e.g. /spa"

  spaRouter$root: 
    type: String
    default: "root"
    desc: "Name of the root file"
  
  spaRouter$folder: 
    type: [String, Function]
    default: "app/"
    desc: "Default folder for all routes. When using `locale` you can provide a function, e.g: (locale) => {\"app/${locale}\"}"

  spaRouter$index: 
    type: String
    default: "index"
    desc: "Filename for empty url"
  
  spaRouter$view:
    type: String
    default: "view"
    desc: "Id of view element"
  
  spaRouter$watch: 
    type: Boolean
    default: !isProd
    _default: "not inProduction"
    desc: "Watch routes.config file for changes"
  
  spaRouter$default: 
    type: String
    default: "/"
    desc: "Default route"

  spaRouter$redirect: 
    type: Boolean
    default: true
    desc: "Redirect all unresolved requests to default route"
  
  spaRouter$plugins: 
    type: Array
    default: [
      "./spa-routes"
      "./spa-jstransformer"
      "./spa-locale"
      "./spa-client"
      "./spa-polyfill"
      "./spa-critical-css"
      "./spa-webpack-manifest"
    ]
    _default: []
    desc: "Spa-router plugins to use. Absolute or relative to CWD path."

  spaRouter$inject: 
    type: Boolean
    default: true
    desc: "Default inject property for all routes. Each route with 'inject:true' will be included in all responses. Reduces requests, but costs more bandwidth."

  spaRouter$client: 
    type: [String, Boolean]
    default: "inject"
    desc: "Inject the client-router directly. True will inject a <script> and expose the file. When set to False, you are responsible to deliver the client, e.g. by using Webpack and `require('leajs-spa-router')`."

  spaRouter$transform:
    type: String
    desc: "Name of a jstransformer to use by default. E.g. 'pug', would need `jstransformer-pug` to be installed"

  spaRouter$transformOptions: 
    type: Object
    default: {cache: false}
    desc: "Options object for jstransformers"
  
  spaRouter$routes: 
    type: Object
    desc: "Routes lookup, will be merged into content of the routes file, if available"
  
  spaRouter$routes$_item:
    type: Object
    desc: "a single route"
  
  spaRouter$routes$_item$file:
    type: [String, Function]
    _default: "name of the route"
    desc: "filename to load. When using `locale` you can provide a function, e.g: (locale) => {\"file.${locale}\"}"

  spaRouter$routes$_item$folder:
    type: [String, Function]
    desc: "Overwrites default folder option"

  spaRouter$routes$_item$inject:
    type: Boolean
    desc: "Overwrites default inject option"
  
  spaRouter$routes$_item$transform:
    type: String
    desc: "Overwrites default transform option"

  spaRouter$routesFile: 
    type: String
    default: "routes.config"
    desc: "Name of routes file"
  
  spaRouter$routesFolder: 
    type: [String, Array]
    default: ["./server","./"]
    desc: "Folders to search for routes file"

  spaRouter$polyfills:
    type: Object
    default: 
      Promise:
        url: "/p/p.js"
        file: require.resolve("yaku/dist/yaku.browser.global.min.js")
        check: "!window.Promise"
    _default: "Promise polyfill yaku"
    desc: "Conditional deliver polyfills"

  spaRouter$polyfills$_item:
    type: [String, Object]
    desc: "Polyfill config object, can be used for a shortcut of `spaRouter.polyfills.$item.check`"

  spaRouter$polyfills$_item$url:
    type: String
    desc: "Url to deliver, will overwrite object key"

  spaRouter$polyfills$_item$check:
    type: String
    desc: "JS condition to check in browser befor polyfill will be fetched"  

  spaRouter$polyfills$_item$file:
    type: String
    desc: "File to deliver"

  webpack: 
    type: Object 
    default: {}
    desc: "Configuration object"

  webpack$output:
    type: String
    _default: "Read from webpack.config 'output.path'"
    desc: "Output folder of webpack"

  webpack$manifest: 
    types: [String, Boolean] 
    default: false
    _default: "Deactivated, when activated defaults to 'manifest.json'"
    desc: "Filename of webpack manifest file"

  webpack$chunkManifest:
    types: [String, Boolean]
    default: false
    _default: "Deactivated, when activated defaults to 'chunk-manifest.json'"
    desc: "Filename of webpack chunk manifest file"

  spaRouter$criticalCss:
    type: [Object, Boolean]
    default: false
    strict: true
    desc: "criticalCss options"

  spaRouter$criticalCss$folder:
    type: String
    _default: "app_build/"
    desc: "Folder where critical/uncritical files are"

  spaRouter$criticalCss$hashed:
    type: Boolean
    _default: "true"
    desc: "Resolve hashed uncritical css file. See https://github.com/paulpflug/get-critical-css#hash"

  spaRouter$criticalCss$critical:
    type: String 
    _default: "_critical"
    desc: "Name of critical css file"

  spaRouter$criticalCss$uncritical:
    type: String 
    _default: "_uncritical"
    desc: "Vame of uncritical css file"