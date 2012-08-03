unless isIE
  describe "Editable.Others", ->
    required = ["plugins/editable/editable.others", "core/helpers"]

    Editable = $el = null
    beforeEach ->
      $el = $("<div/>").prependTo("body")
      class Editable
        api:
          el: $el[0]
          doc: document

    afterEach ->
      $el.remove()

    describe "#start", ->
      ait "makes the el editable", required, (Module, Helpers) ->
        Helpers.include(Editable, Module)

        editable = new Editable()
        editable.start()
        expect($(editable.api.el).attr("contentEditable")).toEqual("true")

      ait "removes the image resize handlers", required, (Module, Helpers) ->
        Helpers.include(Editable, Module)

        spyOn(document, "execCommand")
        editable = new Editable()
        editable.start()
        expect(document.execCommand).toHaveBeenCalledWith("enableObjectResizing", false, false)
