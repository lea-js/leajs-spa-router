# leajs-spa-router

Plugin of [leajs](https://github.com/lea-js/leajs-server).

Single page router.

## Features

- Injects client side router into your routes
- Fallback to server side router for SEO or when no JS allowed
- Routes get bundled to save traffic
- Supports critical css (see [get-critical-css](https://github.com/paulpflug/get-critical-css))
- Supports localized routes
- Can serve polyfills depending on JS functionality
- Supports webpack manifest and chunk manifest

## leajs.config

```js
module.exports = {

  // Configuration of spa router
  // type: Object
  spaRouter: {

    // Namespace for the router e.g. /spa
    base: "", // String

    // Inject the client-router directly. True will inject a <script> and expose the file. When set to False, you are responsible to deliver the client, e.g. by using Webpack and `require('leajs-spa-router')`.
    client: "inject", // [String, Boolean]

    // criticalCss options
    criticalCss: false, // [Object, Boolean]

    // Name of critical css file
    // Default: _critical
    criticalCss.critical: null, // String

    // Folder where critical/uncritical files are
    // Default: app_build/
    criticalCss.folder: null, // String

    // Resolve hashed uncritical css file. See https://github.com/paulpflug/get-critical-css#hash
    // Default: true
    criticalCss.hashed: null, // Boolean

    // Vame of uncritical css file
    // Default: _uncritical
    criticalCss.uncritical: null, // String

    // Default route
    default: "/", // String

    // Default folder for all routes. When using `locale` you can provide a function, e.g: (locale) => {"app/${locale}"}
    folder: "app/", // [String, Function]

    // Filename for empty url
    index: "index", // String

    // Default inject property for all routes. Each route with 'inject:true' will be included in all responses. Reduces requests, but costs more bandwidth.
    inject: true, // Boolean

    // Spa-router plugins to use. Absolute or relative to CWD path.
    // Default:
    plugins: null, // Array

    // Conditional deliver polyfills
    // Default: Promise polyfill yaku
    // type: Object
    // $item ([String, Object]) Polyfill config object, can be used for a shortcut of `spaRouter.polyfills.$item.check`
    // $item.url (String) Url to deliver, will overwrite object key
    // $item.check (String) JS condition to check in browser befor polyfill will be fetched
    // $item.file (String) File to deliver
    polyfills: null, // Object

    // Redirect all unresolved requests to default route
    redirect: true, // Boolean

    // Name of the root file
    root: "root", // String

    // Routes lookup, will be merged into content of the routes file, if available
    // $item (Object) a single route
    // $item.file ([String, Function]) filename to load. When using `locale` you can provide a function, e.g: (locale) => {"file.${locale}"}
    // $item.folder ([String, Function]) Overwrites default folder option
    // $item.inject (Boolean) Overwrites default inject option
    // $item.transform (String) Overwrites default transform option
    routes: null, // Object

    // Name of routes file
    routesFile: "routes.config", // String

    // Folders to search for routes file
    routesFolder: ["./server","./"], // [String, Array]

    // Name of a jstransformer to use by default. E.g. 'pug', would need `jstransformer-pug` to be installed
    transform: null, // String

    // Options object for jstransformers
    transformOptions: {"cache":false}, // Object

    // Id of view element
    view: "view", // String

    // Watch routes.config file for changes
    // Default: not inProduction
    watch: null, // Boolean

  },

  // Configuration object
  // type: Object
  webpack: {

    // Filename of webpack chunk manifest file
    // Default: Deactivated, when activated defaults to 'chunk-manifest.json'
    chunkManifest: null, // [String, Boolean]

    // Filename of webpack manifest file
    // Default: Deactivated, when activated defaults to 'manifest.json'
    manifest: null, // [String, Boolean]

    // Output folder of webpack
    // Default: Read from webpack.config 'output.path'
    output: null, // String

  // …

}
```

## routes.config
Read by [read-conf](https://github.com/paulpflug/read-conf), from `./` or `./server/` by default.
```js
module.exports = {
  "/someRoute": {
    // Clientside: will be called after routing
    after: null, // Function

    // Clientside: will be called before routing
    before: null, // Function

    // filename to load. When using `locale` you can provide a function, e.g: (locale) => {"file.${locale}"}
    // Default: name of the route
    file: null, // [String, Function]

    // Overwrites default folder option
    folder: null, // [String, Function]

    // Overwrites default inject option
    inject: null, // Boolean

    // Overwrites default transform option
    transform: null, // String
  },

  // …

}
```

## License
Copyright (c) 2018 Paul Pflugradt
Licensed under the MIT license.
