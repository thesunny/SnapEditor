# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "plugins/activate/activate"], ($, Activate) ->
  describe "Activate", ->

    api = null
    beforeEach ->
      api = $("<div/>")
      api.activate = ->
      api.isValid = -> true
      api.trigger = ->

    describe "modules", ->
      it "includes browser specific functions", ->
        expect(-> Activate.addActivateEvents(api)).not.toThrow()

    describe "#finishActivate", ->
      it "triggers the activation sequence", ->
        spyOn(api, "trigger")
        Activate.finishActivate(api)
        expect(api.trigger.callCount).toEqual(3)
        expect(api.trigger.argsForCall[0]).toEqual(["snapeditor.before_activate"])
        expect(api.trigger.argsForCall[1]).toEqual(["snapeditor.activate"])
        expect(api.trigger.argsForCall[2]).toEqual(["snapeditor.ready"])

    describe "#deactivate", ->
      it "adds the activate events", ->
        spyOn(Activate, "addActivateEvents")
        Activate.deactivate(api)
        expect(Activate.addActivateEvents).toHaveBeenCalled()

    describe "#isLink", ->
      it "returns true if the element is a link", ->
        expect(Activate.isLink($("<a/>"))).toBeTruthy()

      it "returns true if the element is inside link", ->
        $a = $("<a/>")
        $span = $("<span/>").appendTo($a)
        expect(Activate.isLink($span)).toBeTruthy()

      it "returns false otherwise", ->
        expect(Activate.isLink($("<div/>"))).toBeFalsy()
