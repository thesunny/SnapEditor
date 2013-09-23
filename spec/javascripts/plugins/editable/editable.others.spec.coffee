# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
unless isIE
  require ["jquery.custom", "plugins/editable/editable.others"], ($, Others) ->
    describe "Editable.Others", ->
      api = null
      beforeEach ->
        api =
          el: $("<div/>")[0]
          doc: document

      describe "#start", ->
        it "makes the el editable", ->
          Others.start(api)
          expect($(api.el).attr("contentEditable")).toEqual("true")

        it "removes the image resize handlers", ->
          spyOn(document, "execCommand")
          Others.start(api)
          expect(document.execCommand).toHaveBeenCalledWith("enableObjectResizing", false, false)
