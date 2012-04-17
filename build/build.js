({
  baseUrl: "../javascripts",
  paths: {
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
