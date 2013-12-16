# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["core/helpers/helpers.keyboard"], (Keyboard) ->
  describe "Helpers.Keyboard", ->
    describe "#keyOf", ->
      event = null
      beforeEach ->
        event = { type: "keydown" }

      it "returns function keys on keydown", ->
        event.which = 111
        expect(Keyboard.keyOf(event)).toEqual("o")
        event.which = 112
        expect(Keyboard.keyOf(event)).toEqual("f1")
        event.which = 123
        expect(Keyboard.keyOf(event)).toEqual("f12")
        event.which = 124
        expect(Keyboard.keyOf(event)).toEqual("|")

      it "returns non function keys when not keydown", ->
        event.type = "keypress"
        event.which = 112
        expect(Keyboard.keyOf(event)).toNotBe("f1")
        event.which = 123
        expect(Keyboard.keyOf(event)).toNotBe("f12")

      it "returns defined special keys", ->
        event.which = 13
        expect(Keyboard.keyOf(event)).toEqual("enter")
        event.which = 39
        expect(Keyboard.keyOf(event)).toEqual("right")
        event.which = 46
        expect(Keyboard.keyOf(event)).toEqual("delete")

    describe "#normalizeKeys", ->
      it "separates out the special keys from the key", ->
        spyOn(Keyboard, "buildKey").andReturn("key")
        expect(Keyboard.normalizeKeys("ctrl+shift+alt+a")).toEqual("key")
        expect(Keyboard.buildKey).toHaveBeenCalledWith("a", ["ctrl", "shift", "alt"])

    describe "#buildKey", ->
      it "returns the key when given a single key", ->
        expect(Keyboard.buildKey("a")).toEqual("a")

      it "combines the special key with the key", ->
        expect(Keyboard.buildKey("a", ["ctrl"])).toEqual("ctrl+a")

      it "combines the sorted special keys with the key", ->
        expect(Keyboard.buildKey("a", ["shift", "ctrl"])).toEqual("ctrl+shift+a")
