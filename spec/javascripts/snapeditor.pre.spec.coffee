# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "snapeditor.pre"], ($, S) ->
  describe "SnapEditor.Pre", ->
    describe "#matchPath", ->
      it "returns the current path", ->
        expect(window.SnapEditor.matchPath("snapeditor.js")).toEqual(".")

      it "returns the root path", ->
        expect(window.SnapEditor.matchPath("/snapeditor.js")).toEqual("/")

      it "returns a relative path", ->
        expect(window.SnapEditor.matchPath("rel/snapeditor.js")).toEqual("rel/")

      it "returns an absolute path", ->
        expect(window.SnapEditor.matchPath("/abs/snapeditor.js")).toEqual("/abs/")
