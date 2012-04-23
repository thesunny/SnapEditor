describe "Keyboard", ->
  required = ["plugins/keyboard/keyboard"]

  describe "#add", ->
    ait "adds the key when given a key and a function", required, (Keyboard) ->
      keyboard = new Keyboard([], "keydown")
      keyboard.add("ctrl.shift.a", (->))
      expect(keyboard.keys["ctrl.shift.a"]).toBeDefined()

    ait "adds all the keys when given a map", required, (Keyboard) ->
      keyboard = new Keyboard([], "keydown")
      keyboard.add("ctrl.shift.a": (->), "b": (->))
      expect(keyboard.keys["ctrl.shift.a"]).toBeDefined()
      expect(keyboard.keys["b"]).toBeDefined()

  describe "#remove", ->
    ait "removes the key when given a key", required, (Keyboard) ->
      keyboard = new Keyboard([], "keydown")
      keyboard.add("ctrl.shift.a", (->))
      expect(keyboard.keys["ctrl.shift.a"]).toBeDefined()
      keyboard.remove("ctrl.shift.a")
      expect(keyboard.keys["ctrl.shift.a"]).toBeUndefined()

    ait "removes all the keys when given an array", required, (Keyboard) ->
      keyboard = new Keyboard([], "keydown")
      keyboard.add("ctrl.shift.a": (->), "b": (->))
      expect(keyboard.keys["ctrl.shift.a"]).toBeDefined()
      expect(keyboard.keys["b"]).toBeDefined()
      keyboard.remove(["ctrl.shift.a", "b"])
      expect(keyboard.keys["ctrl.shift.a"]).toBeUndefined()
      expect(keyboard.keys["b"]).toBeUndefined()

  describe "#buildKey", ->
    ait "returns the key when given a single key", required, (Keyboard) ->
      keyboard = new Keyboard([], "keydown")
      expect(keyboard.buildKey("a")).toEqual("a")

    ait "combines the special key with the key", required, (Keyboard) ->
      keyboard = new Keyboard([], "keydown")
      expect(keyboard.buildKey("a", ["ctrl"])).toEqual("ctrl.a")

    ait "combines the sorted special keys with the key", required, (Keyboard) ->
      keyboard = new Keyboard([], "keydown")
      expect(keyboard.buildKey("a", ["shift", "ctrl"])).toEqual("ctrl.shift.a")

  describe "#normalize", ->
    ait "separates out the special keys from the key", required, (Keyboard) ->
      keyboard = new Keyboard([], "keydown")
      spyOn(keyboard, "buildKey").andReturn("key")
      expect(keyboard.normalize("ctrl.shift.alt.a")).toEqual("key")
      expect(keyboard.buildKey).toHaveBeenCalledWith("a", ["ctrl", "shift", "alt"])
