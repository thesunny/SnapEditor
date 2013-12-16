# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "core/helpers", "core/toolbar/toolbar.button"], ($, Helpers, Button) ->
  describe "Toolbar.Button", ->
    it "attaches the options", ->
      button = new Button("Test", test1: true, test2: "hello", items: [])
      expect(button.test1).toBeTruthy()
      expect(button.test2).toEqual("hello")

    it "clones the items", ->
      items = [1, 2, 3]
      button = new Button("Test", items: items)
      expect(button.items).not.toBe(items)
