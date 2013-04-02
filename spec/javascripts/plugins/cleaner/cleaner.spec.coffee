require ["jquery.custom", "plugins/cleaner/cleaner"], ($, Cleaner) ->
  $editable = cleaner = null
  describe "Cleaner", ->
    $editable = cleaner = null
    beforeEach ->
      $editable = addEditableFixture()
      cleaner = window.SnapEditor.internalPlugins.cleaner

    afterEach ->
      $editable.remove()

    describe "#findTopNode", ->
      beforeEach ->
        $editable.html("this <b>must</b> be a test<div>or <i>maybe</i> not</div>")

      it "looks up the parent chain and returns the textnode at the top", ->
        node = cleaner.findTopNode($editable[0], $editable[0].childNodes[0])
        expect(node).toBe($editable[0].childNodes[0])

      it "looks up the parent chain and returns the element at the top", ->
        node = cleaner.findTopNode($editable[0], $editable.find("i")[0])
        expect(node).toBe($editable.find("div")[0])

    describe "#expandTopNode", ->
      it "returns the node given a block node", ->
        $editable.html("this <div>is a block</div> yo")
        node = cleaner.expandTopNode($editable.find("div")[0], true)
        expect(node).toBe($editable.find("div")[0])

      it "returns the furthest inline node before a block going backwards", ->
        $editable.html("<div>stop</div>this is <b>some</b> text")
        node = cleaner.expandTopNode($editable.find("b")[0], true)
        expect(node).toBe($editable.find("div")[0].nextSibling)

      it "returns the furthest inline node before a block going forwards", ->
        $editable.html("this is <b>some</b> text<div>stop</div>")
        node = cleaner.expandTopNode($editable.find("b")[0], false)
        expect(node).toBe($editable.find("div")[0].previousSibling)

      it "returns the furthest inline node before the beginning going backwards", ->
        $editable.html("this <i>is</i> just <b>some</b> random <span>text</span> here")
        node = cleaner.expandTopNode($editable.find("b")[0], true)
        expect(node).toBe($editable[0].childNodes[0])

      it "returns the furthest inline node before the end going forwards", ->
        $editable.html("this <i>is</i> just <b>some</b> random <span>text</span> here")
        node = cleaner.expandTopNode($editable.find("b")[0], false)
        expect(node).toBe($editable[0].lastChild)
