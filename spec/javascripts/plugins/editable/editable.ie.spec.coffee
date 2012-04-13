if isIE
  describe "Editable.IE", ->
    required = ["cs!plugins/editable/editable.ie", "cs!core/helpers"]

    Editable = $el = null
    beforeEach ->
      $el = $("<div/>").prependTo("body")
      class Editable
        api: { el: $el[0] }

    afterEach ->
      $el.remove()

    describe "#start", ->
      ait "prevents the image resize handlers from working", required, (Module, Helpers) ->
        Helpers.include(Editable, Module)

        editable = new Editable()
        spyOn(editable, "preventResize")
        editable.start()

        # NOTE: The event handler is attached using native JavaScript. Hence,
        # we need to fire the event using native JavaScript.
        $el[0].fireEvent("onresizestart", document.createEventObject())
        expect(editable.preventResize).toHaveBeenCalled()

      ait "makes the el editable", required, (Module, Helpers) ->
        Helpers.include(Editable, Module)

        editable = new Editable()
        editable.start()
        expect($(editable.api.el).attr("contentEditable")).toEqual("true")

    describe "#finishBrowser", ->
      ait "detaches the onresizestart event handler", required, (Module, Helpers) ->
        Helpers.include(Editable, Module)

        editable = new Editable()
        spyOn(editable, "preventResize")
        editable.start()
        editable.finishBrowser()

        # NOTE: The event handler is attached using native JavaScript. Hence,
        # we need to fire the event using native JavaScript.
        $el[0].fireEvent("onresizestart", document.createEventObject())
        expect(editable.preventResize).not.toHaveBeenCalled()

    describe "#preventResize", ->
      ait "sets the return value to false", required, (Module, Helpers) ->
        Helpers.include(Editable, Module)

        e = { returnValue: true }
        editable = new Editable()
        editable.preventResize(e)
        expect(e.returnValue).toBeFalsy()
