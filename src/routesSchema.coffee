module.exports =
  __strict: false 
  _item:
    type: Object
    desc: "a single route"
  
  _item$file:
    type: [String, Function]
    _default: "name of the route"
    desc: "filename to load. When using `locale` you can provide a function, e.g: (locale) => {\"file.${locale}\"}"

  _item$folder:
    type: [String, Function]
    desc: "Overwrites default folder option"

  _item$inject:
    type: Boolean
    desc: "Overwrites default inject option"
  
  _item$transform:
    type: String
    desc: "Overwrites default transform option"

  _item$before:
    type: Function
    desc: "Clientside: will be called before routing"

  _item$after:
    type: Function
    desc: "Clientside: will be called after routing"