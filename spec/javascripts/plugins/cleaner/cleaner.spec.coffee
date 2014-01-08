# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "plugins/cleaner/cleaner"], ($, Cleaner) ->
  $editable = null
  describe "Cleaner", ->
    $editable = null
    beforeEach ->
      $editable = addEditableFixture()

    afterEach ->
      $editable.remove()

    describe "#expandTopNode", ->
      it "returns the node given a block node", ->
        $editable.html("this <div>is a block</div> yo")
        node = Cleaner.expandTopNode($editable.find("div")[0], true)
        expect(node).toBe($editable.find("div")[0])

      it "returns the furthest inline node before a block going backwards", ->
        $editable.html("<div>stop</div>this is <b>some</b> text")
        node = Cleaner.expandTopNode($editable.find("b")[0], true)
        expect(node).toBe($editable.find("div")[0].nextSibling)

      it "returns the furthest inline node before a block going forwards", ->
        $editable.html("this is <b>some</b> text<div>stop</div>")
        node = Cleaner.expandTopNode($editable.find("b")[0], false)
        expect(node).toBe($editable.find("div")[0].previousSibling)

      it "returns the furthest inline node before the beginning going backwards", ->
        $editable.html("this <i>is</i> just <b>some</b> random <span>text</span> here")
        node = Cleaner.expandTopNode($editable.find("b")[0], true)
        expect(node).toBe($editable[0].childNodes[0])

      it "returns the furthest inline node before the end going forwards", ->
        $editable.html("this <i>is</i> just <b>some</b> random <span>text</span> here")
        node = Cleaner.expandTopNode($editable.find("b")[0], false)
        expect(node).toBe($editable[0].lastChild)
