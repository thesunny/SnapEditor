({
  baseUrl: "../javascripts",
  pragmasOnSave: {
    excludeCoffeeScript: true
  },
  name: "../build/almond.js",
  include: "snapeditor",
  out: "snapeditor.js",
  optimize: "uglify",
  wrap: true
})
