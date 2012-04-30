describe "Toolbar.Floating.Displayer", ->
  required = ["core/toolbar/toolbar.floating.displayer"]

  $container = $el = $toolbar = null
  beforeEach ->
    $container = $("<div/>").prependTo("body")
    $el = $("<div>text</div>").appendTo($container)
    $toolbar = $('<div style="display:none">toolbar</div>').appendTo($container)

  afterEach ->
    $container.remove()

  describe "#overlapSpaceFromElTop", ->
    ait "returns 0 when there is enough space at the top", required, (Displayer) ->
      displayer = new Displayer($toolbar, $el)
      spyOn(displayer, "toolbarSize").andReturn({ y: 50 })
      spyOn(displayer, "elCoords").andReturn({ top: 200 })
      expect(displayer.overlapSpaceFromElTop()).toEqual(0)

    ait "returns a positive number when there is overlapping", required, (Displayer) ->
      displayer = new Displayer($toolbar, $el)
      spyOn(displayer, "toolbarSize").andReturn({ y: 50 })
      spyOn(displayer, "elCoords").andReturn({ top: 25 })
      expect(displayer.overlapSpaceFromElTop()).toEqual(25)

  describe "#isCursorInOverlapSpace", ->
    ait "returns true when the cursor is in the overlap space", required, (Displayer) ->
      displayer = new Displayer($toolbar, $el)
      spyOn(displayer, "cursorPosition").andReturn(110)
      spyOn(displayer, "elCoords").andReturn({ top: 100 })
      spyOn(displayer, "overlapSpaceFromElTop").andReturn(50)
      expect(displayer.isCursorInOverlapSpace()).toBeTruthy()

    ait "returns false when the cursor is not in the overlap space", required, (Displayer) ->
      displayer = new Displayer($toolbar, $el)
      spyOn(displayer, "cursorPosition").andReturn(160)
      spyOn(displayer, "elCoords").andReturn({ top: 100 })
      spyOn(displayer, "overlapSpaceFromElTop").andReturn(50)
      expect(displayer.isCursorInOverlapSpace()).toBeFalsy()
