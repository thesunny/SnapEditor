# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# getXhr() and fetchText() are taken from cs.custom.cs.
# NOTE: The following variables look like they may be in the global scope, but
# during CoffeeScript compilation, this entire file is wrapped in a function.
progIds = ['Msxml2.XMLHTTP', 'Microsoft.XMLHTTP', 'Msxml2.XMLHTTP.4.0']
getXhr = ->
  # Would love to dump the ActiveX crap in here. Need IE 6 to die first.
  if typeof XMLHttpRequest != "undefined"
    return new XMLHttpRequest()
  else
    for i in [0..2]
      progId = progIds[i]
      try
        xhr = new ActiveXObject(progId)
      catch e

      if xhr
        progIds = [progId]  # so faster next time
        break

  throw new Error("getXhr(): XMLHttpRequest not available") unless !xhr

  return xhr

fetchText = (url, callback) ->
  xhr = getXhr()
  xhr.open('GET', url, false)
  xhr.send(null)
  # Do not explicitly handle errors, those should be
  # visible via console output in the browser.
  callback(xhr.responseText) if xhr.readyState == 4

addScriptToDom = (text) ->
  # Push the script directly onto the page.
  # NOTE: Don't use eval() because the scope will be set to this callback.
  script = document.createElement("script")
  script.type = "text/javascript"
  script.text = text
  document.getElementsByTagName("head")[0].appendChild(script)

# Load require.js.
# In require.js, it sets a timeout of 0 before it is available. However, this
# slight pause causes it to be taken out of the normal flow and is, in a sense,
# asynchronous. This really screws up the tests. The setTimeout is dependent on
# whether setTimeout is defined. Hence, to get around this, we remove
# setTimeout before executing require.js and reset it afterwards.
fetchText("lib/require.js", (responseText) ->
  addScriptToDom("
    oldSetTimeout = setTimeout;
    setTimeout = undefined;
    #{responseText}
    ;setTimeout = oldSetTimeout;
  ")
)

# Override require.load because it loads modules asynchronously. This loads the
# modules synchronously.
require.load = (context, moduleName, url) ->
  fetchText(url, (responseText) ->
    addScriptToDom(responseText)
    context.completeLoad(moduleName)
  )

# Configuration for require.js.
require.config
  baseUrl: "javascripts"
