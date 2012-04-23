({
  baseUrl: "../javascripts",
  paths: {
    "CoffeeScript": "../lib/coffee-script",
    "cs": "../lib/csBuild",
    "csBuild": "../lib/cs"
  },
  pragmasOnSave: {
    excludeCoffeeScript: true
  },
  name: "../build/almond.js",
  include: "snapeditor",
  out: "snapeditor.js",
  optimize: "uglify",
  wrap: true
})
