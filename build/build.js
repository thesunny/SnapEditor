({
  baseUrl: "../javascripts",
  paths: {
    "order": "../lib/orders",
    "cs": "../lib/cs",
    "text": "../lib/text",
    "domReady": "../lib/domReady"
  },
  pragmasOnSave: {
    excludeCoffeeScript: true
  },
  name: "../build/almond.js",
  include: "snapeditor",
  out: "snapeditor.js",
  wrap: true
})
