require ["jquery.custom", "plugins/image/image.single_uploader", "core/helpers", "core/range"], ($, Uploader, Helpers, Range) ->
  describe "Image.SingleUploader", ->
    $editable = uploader = null
    beforeEach ->
      $editable = addEditableFixture()
      uploader = new Uploader()
      uploader.api =
        createElement: (name) -> document.createElement(name)
        find: (selector) -> $(document).find(selector)
        select: (el) -> (new Range($editable[0], el)).select()

    afterEach ->
      $editable.remove()

    describe "#isValidExtension", ->
      it "returns true when the extension is allowed", ->
        expect(uploader.isValidExtension("image.png")).toBeTruthy()

      it "returns false when the extension is not allowed", ->
        expect(uploader.isValidExtension("image.txt")).toBeFalsy()

      it "returns false when there is no extension", ->
        expect(uploader.isValidExtension("image")).toBeFalsy()

    describe "#insertImage", ->
      beforeEach ->
        $editable.html("hello")
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setEnd($editable[0].childNodes[0], 3)
        else
          range.range.findText("hel")
        range.collapse(false).select()
        uploader.range = range
        spyOn(uploader, "update")
        uploader.insertImage("/spec/javascripts/support/assets/images/stub.png", 560, 372)

      it "adds an image", ->
        expect($editable.find("img").length).toEqual(1)

      it "adds an image with the src, width, and height set", ->
        $img = $editable.find("img")
        # IE7 adds the URL including the domain. Hence we use match.
        expect($img.attr("src")).toMatch("/spec/javascripts/support/assets/images/stub.png$")
        expect($img.attr("width")).toEqual("560")
        expect($img.attr("height")).toEqual("372")

      it "adds the image where the range is", ->
        childNodes = $editable[0].childNodes
        expect(childNodes.length).toEqual(3)
        expect(childNodes[0].nodeValue).toEqual("hel")
        expect($(childNodes[1]).tagName()).toEqual("img")
        expect(childNodes[2].nodeValue).toEqual("lo")

      it "selects the image", ->
        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect(clean($editable.html())).toEqual("hel<b></b>lo")

      it "updates the api", ->
        expect(uploader.update).toHaveBeenCalled()
