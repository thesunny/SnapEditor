/*
Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
For licensing, see LICENSE.
*/
({
  baseUrl: "../javascripts",
  pragmasOnSave: {
    excludeCoffeeScript: true
  },
  name: "../build/almond.js",
  include: "snapeditor",
  out: "snapeditor.js",
  optimize: "uglify",
  wrap: {
    startFile: "start.frag",
    end: "}());"
  },
  paths: {
    "jquery.ui.widget": "../lib/jQuery-File-Upload/js/vendor/jquery.ui.widget",
    "jquery.iframe-transport": "../lib/jQuery-File-Upload/js/jquery.iframe-transport",
    "jquery.fileupload": "../lib/jQuery-File-Upload/js/jquery.fileupload",
    "jquery.fileupload-image": "../lib/jQuery-File-Upload/js/jquery.fileupload-image",
    "jquery.fileupload-process": "../lib/jQuery-File-Upload/js/jquery.fileupload-process",
    "load-image": "../lib/JavaScript-Load-Image/js/load-image",
    "load-image-meta": "../lib/JavaScript-Load-Image/js/load-image-meta",
    "load-image-exif": "../lib/JavaScript-Load-Image/js/load-image-exif",
    //"load-image-exif-map": "../lib/JavaScript-Load-Image/js/load-image-exif-map",
    "load-image-ios": "../lib/JavaScript-Load-Image/js/load-image-ios",
    //"load-image-orientation": "../lib/JavaScript-Load-Image/js/load-image-orientation",
    "canvas-to-blob": "../lib/JavaScript-Canvas-to-Blob/js/canvas-to-blob"
  }
})
