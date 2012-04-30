require ["jquery.custom", "core/contexts"], ($, Contexts) ->
  describe "Contexts", ->
    $editable = $div = contexts = null
    beforeEach ->
      $editable = addEditableFixture()
      $div = $('<div class="top">some <b>bold and <i>italic</i></b> text with an <img src="spec/javascripts/support/images/stub.png"> in it</div>')
      api = $("<div/>")
      api.el = $editable[0]
      contexts = new Contexts(api)

    afterEach ->
      $editable.remove()

    describe "#updateContexts", ->
      it "updates the current contexts", ->
      it "triggers an update with the matched contexts and removed contexts", ->

    describe "#getRemovedContexts", ->
      it "returns the removed contexts", ->
        contexts.currentContexts = ".top": true, "b": true
        removedContexts = contexts.getRemovedContexts(".top": true, ".top b": true)
        expect(removedContexts.length).toEqual(1)
        expect(removedContexts[0]).toEqual("b")
