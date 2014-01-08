# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["core/keyboard"], (Keyboard) ->
  describe "Keyboard", ->
    keyboard = null
    beforeEach ->
      keyboard = new Keyboard($("<div/>"), "keydown")

    describe "#add", ->
      it "adds the key when given a key and a function", ->
        keyboard.add("ctrl.shift.a", (->))
        expect(keyboard.keys["ctrl.shift.a"]).toBeDefined()

      it "adds all the keys when given a map", ->
        keyboard.add("ctrl.shift.a": (->), "b": (->))
        expect(keyboard.keys["ctrl.shift.a"]).toBeDefined()
        expect(keyboard.keys["b"]).toBeDefined()

    describe "#remove", ->
      it "removes the key when given a key", ->
        keyboard.add("ctrl.shift.a", (->))
        expect(keyboard.keys["ctrl.shift.a"]).toBeDefined()
        keyboard.remove("ctrl.shift.a")
        expect(keyboard.keys["ctrl.shift.a"]).toBeUndefined()

      it "removes all the keys when given an array", ->
        keyboard.add("ctrl.shift.a": (->), "b": (->))
        expect(keyboard.keys["ctrl.shift.a"]).toBeDefined()
        expect(keyboard.keys["b"]).toBeDefined()
        keyboard.remove(["ctrl.shift.a", "b"])
        expect(keyboard.keys["ctrl.shift.a"]).toBeUndefined()
        expect(keyboard.keys["b"]).toBeUndefined()
