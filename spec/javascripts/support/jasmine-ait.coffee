# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# Taken from http://blog.pixelingene.com/2011/12/simple-helper-method-for-async-testing-with-jasmine/
#
# We need this because Jasmine's functions are synchronous. However, RequireJS
# is asynchronous. Therefore, before RequireJS has a chance to load any files,
# Jasmine is already finished running the tests.
#
# This workaround basically loads all the required files first, then runs the
# test.
#
# We also load the custom jQuery for the tests.
window.ait = (description, testModules, testFn) ->
  it description, ->
    # Require the custom jQuery. We don't use #unshift() because that would
    # modify the actual modules array.
    modules = ["jquery.custom"].concat(testModules)
    readyModules = []
    waitsFor ->
      require modules, -> readyModules = arguments
      readyModules.length is modules.length # return true only if all modules are ready

    runs ->
      # Replace $ with the custom jQuery only once.
      unless window.$.SNAPEDITOR_CUSTOM_JQUERY
        window.$ = readyModules[0]
        window.$.SNAPEDITOR_CUSTOM_JQUERY = true
      arrayOfModules = Array.prototype.slice.call readyModules, 1
      testFn(arrayOfModules...)
