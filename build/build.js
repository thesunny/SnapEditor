({
  baseUrl: "../javascripts",
  paths: {
    "CoffeeScript": "../lib/coffee-script",
    "cs": "../lib/cs"
  },
  pragmasOnSave: {
    excludeCoffeeScript: true
  },
  name: "../build/almond.js",
  include: "snapeditor",
  out: "snapeditor.js",
  wrap: true
})
