/*
Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
For licensing, see LICENSE.
*/
// cs.js loads all modules asynchronously. The following are all copied
// directly from cs.js, but with modifications so that the modules are loaded
// synchronously.
define(["../lib/cs"], function (CS) {
  var getXhr = function () {
    //Would love to dump the ActiveX crap in here. Need IE 6 to die first.
    var xhr, i, progId,
        progIds = ['Msxml2.XMLHTTP', 'Microsoft.XMLHTTP', 'Msxml2.XMLHTTP.4.0'];
    if (typeof XMLHttpRequest !== "undefined") {
      return new XMLHttpRequest();
    } else {
      for (i = 0; i < 3; i++) {
        progId = progIds[i];
        try {
          xhr = new ActiveXObject(progId);
        } catch (e) {}

        if (xhr) {
          progIds = [progId];  // so faster next time
          break;
        }
      }
    }

    if (!xhr) {
      throw new Error("getXhr(): XMLHttpRequest not available");
    }

    return xhr;
  };

  var fetchText = function (url, callback) {
    var xhr = getXhr();
    xhr.open('GET', url, false);
    xhr.send(null);
    //Do not explicitly handle errors, those should be
    //visible via console output in the browser.
    if (xhr.readyState === 4) {
      callback(xhr.responseText);
    }
  };

  CS.load = function (name, parentRequire, load, config) {
    var path = parentRequire.toUrl(name + '.coffee');
    fetchText(path, function (text) {

      //Do CoffeeScript transform.
      text = CS.get().compile(text, config.CoffeeScript);

      //Hold on to the transformed text if a build.
      if (config.isBuild) {
        buildMap[name] = text;
      }

      //IE with conditional comments on cannot handle the
      //sourceURL trick, so skip it if enabled.
      //[>@if (@_jscript) @else @<]
      if (!config.isBuild) {
        text += "\r\n//@ sourceURL=" + path;
      }
      //[>@end@<]

      load.fromText(name, text);

      //Give result to load. Need to wait until the module
      //is fully parse, which will happen after this
      //execution.
      parentRequire([name], function (value) {
        load(value);
      });
    });
  };
  return CS;
});
