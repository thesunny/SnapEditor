require ["core/keyboard/keyboard"], (Keyboard) ->
  describe "Keyboard", ->
    keyboard = null
    beforeEach ->
      keyboard = new Keyboard($("<div/>"), {})

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

    describe "#buildKey", ->
      it "returns the key when given a single key", ->
        expect(keyboard.buildKey("a")).toEqual("a")

      it "combines the special key with the key", ->
        expect(keyboard.buildKey("a", ["ctrl"])).toEqual("ctrl.a")

      it "combines the sorted special keys with the key", ->
        expect(keyboard.buildKey("a", ["shift", "ctrl"])).toEqual("ctrl.shift.a")

    describe "#normalize", ->
      it "separates out the special keys from the key", ->
        spyOn(keyboard, "buildKey").andReturn("key")
        expect(keyboard.normalize("ctrl.shift.alt.a")).toEqual("key")
        expect(keyboard.buildKey).toHaveBeenCalledWith("a", ["ctrl", "shift", "alt"])
