# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "core/widget/widget.object", "core/range", "core/helpers"], ($, WidgetObject, Range, Helpers) ->
  describe "WidgetObject", ->
    describe "#insertEl", ->
      $editable = $start = api = range = null
      beforeEach ->
        $editable = addEditableFixture()
        $start = $('<div id="start">start</div>').appendTo($editable)
        api =
          createElement: (tag) -> document.createElement(tag)
          getRange: -> new Range($editable[0], window)
          find: (selector) -> $(selector)
        Helpers.delegate(api, "getRange()", "insert", "delete")
        range = new Range($editable[0])

      afterEach ->
        $editable.remove()

      it "inserts the element at the cursor", ->
        if hasW3CRanges
          range.range.setStart($start[0].childNodes[0], 1)
        else
          range.range.findText("tart")
        range.collapse(true).select()
        widgetObject = new WidgetObject(api, "widget")
        spyOn(widgetObject, "insertOverlay")
        widgetObject.insertEl()
        expect(clean($start.html())).toEqual("s<div class=widget contenteditable=false></div>tart")

      it "inserts the element at the selection", ->
        if hasW3CRanges
          range.range.setStart($start[0].childNodes[0], 1)
          range.range.setEnd($start[0].childNodes[0], 4)
        else
          range.range.findText("tar")
        range.select()
        widgetObject = new WidgetObject(api, "widget")
        spyOn(widgetObject, "insertOverlay")
        widgetObject.insertEl()
        expect(clean($start.html())).toEqual("s<div class=widget contenteditable=false></div>t")

      it "sets the element", ->
        if hasW3CRanges
          range.range.setStart($start[0].childNodes[0], 1)
        else
          range.range.findText("tart")
        range.collapse().select()
        widgetObject = new WidgetObject(api, "widget")
        spyOn(widgetObject, "insertOverlay")
        widgetObject.insertEl()
        expect(clean($start.html())).toEqual("s<div class=widget contenteditable=false></div>tart")
