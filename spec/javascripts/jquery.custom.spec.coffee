describe "jquery", ->
  required = ["cs!jquery.custom"]

  $editable = null
  beforeEach ->
    $editable = addEditableFixture()

  afterEach ->
    $editable.remove()

  describe "#tagName", ->
    ait "returns the lowercased version of the tagname", required, ($) ->
      $el = $('<div id="el"></div>').appendTo($editable)
      expect($el.tagName()).toEqual("div")

  describe "#getCoordinates", ->
    ait "returns the correct coordinates", required, ($) ->
      $el = $('<div id="el"></div>').appendTo($editable)
      $el.attr("style", "\
        position: fixed; \
        top: 50px; \
        left: 60px; \
        width: 200px; \
        height: 100px;\
      ")
      coords = $el.getCoordinates()
      expect(coords.top).toEqual(50)
      expect(coords.bottom).toEqual(150)
      expect(coords.left).toEqual(60)
      expect(coords.right).toEqual(260)
      expect(coords.width).toEqual(200)
      expect(coords.height).toEqual(100)

  describe "#getScroll", ->
    ait "returns the 0 with no scrolling", required, ($) ->
      scroll = $(window).getScroll()
      expect(scroll.x).toEqual(0)
      expect(scroll.y).toEqual(0)

    ait "returns the correct scroll", required, ($) ->
      $el = $('<div id="el"></div>').appendTo($editable)
      $el.attr("style", "width: 6000px; height: 9000px;")
      window.scrollTo(300, 500)
      scroll = $(window).getScroll()
      expect(scroll.x).toEqual(300)
      expect(scroll.y).toEqual(500)
      window.scrollTo(0, 0)

  describe ".mustache", ->
    ait "renders the given template and view", required, ($) ->
      template = "before {{value}} after"
      view = value: "test"
      expect($.mustache(template, view)).toEqual("before test after")

  describe "#mustache", ->
    ait "renders the given view using the element's HTML", required, ($) ->
      $template = $("<div>before {{value}} after</div>")
      view = value: "test"
      expect($template.mustache(view)).toEqual("before test after")
