describe "helpers", ->
  required = ["cs!core/helpers"]

  describe "#p", ->
    ait "console logs or alerts a single argument", required, (Helpers) ->
      Helpers.p("Testing 1, 2, 3!")
    ait "console logs or alerts multiple arguments", required, (Helpers) ->
      Helpers.p("Testing", 1)

  describe "#isElement", ->
    ait "returns true for an element", required, (Helpers) ->
      el = document.createElement("div")
      expect(Helpers.isElement(el)).toBeTruthy()
    ait "returns false for a text node", required, (Helpers) ->
      text = document.createTextNode("This is text")
      expect(Helpers.isElement(text)).toBeFalsy()

  describe "#isTextnode", ->
    ait "returns true for a text node", required, (Helpers) ->
      text = document.createTextNode("This is text")
      expect(Helpers.isTextnode(text)).toBeTruthy()
    ait "returns false for an element", required, (Helpers) ->
      el = document.createElement("div")
      expect(Helpers.isTextnode(el)).toBeFalsy()

  describe "#typeOf", ->
    ait "returns boolean", required, (Helpers) ->
      expect(Helpers.typeOf(true)).toEqual("boolean")
      expect(Helpers.typeOf(false)).toEqual("boolean")
    ait "returns number", required, (Helpers) ->
      expect(Helpers.typeOf(1)).toEqual("number")
      expect(Helpers.typeOf(-1)).toEqual("number")
      expect(Helpers.typeOf(0)).toEqual("number")
      expect(Helpers.typeOf(1.233)).toEqual("number")
    ait "returns string", required, (Helpers) ->
      expect(Helpers.typeOf("")).toEqual("string")
      expect(Helpers.typeOf("test")).toEqual("string")
    ait "returns function", required, (Helpers) ->
      expect(Helpers.typeOf(->)).toEqual("function")
      expect(Helpers.typeOf(Helpers.typeOf)).toEqual("function")
    ait "returns array", required, (Helpers) ->
      expect(Helpers.typeOf([])).toEqual("array")
      expect(Helpers.typeOf([1, 2, 3])).toEqual("array")
    ait "returns date", required, (Helpers) ->
      expect(Helpers.typeOf(new Date())).toEqual("date")
    ait "returns regexp", required, (Helpers) ->
      expect(Helpers.typeOf(/a/)).toEqual("regexp")
    ait "returns element", required, (Helpers) ->
      el = document.createElement("div")
      expect(Helpers.typeOf(el)).toEqual("element")
    ait "returns textnode", required, (Helpers) ->
      el = document.createTextNode("This is text")
      expect(Helpers.typeOf(el)).toEqual("textnode")
    ait "returns window", required, (Helpers) ->
      expect(Helpers.typeOf(window)).toEqual("window")
    ait "returns object", required, (Helpers) ->
      expect(Helpers.typeOf({})).toEqual("object")

  describe "#extend", ->
    ait "extends all the methods", required, (Helpers) ->
      Module = { moduleKey: "module value", moduleFn: -> "module" }
      class TestClass
        @classKey: "class value"
        @classFn: -> "class"
      expect(TestClass.classKey).toEqual("class value")
      expect(TestClass.classFn()).toEqual("class")
      expect(TestClass.moduleKey).toBeUndefined()
      expect(TestClass.moduleFn).toBeUndefined()
      Helpers.extend(TestClass, Module)
      expect(TestClass.classKey).toEqual("class value")
      expect(TestClass.classFn()).toEqual("class")
      expect(TestClass.moduleKey).toBeDefined()
      expect(TestClass.moduleFn).toBeDefined()
      expect(TestClass.moduleKey).toEqual("module value")
      expect(TestClass.moduleFn()).toEqual("module")

  describe "#include", ->
    ait "includes all the methods", required, (Helpers) ->
      Module = { moduleKey: "module value", moduleFn: -> "module" }
      class TestClass
        classKey: "class value"
        classFn: -> "class"
      test = new TestClass()
      expect(test.classKey).toEqual("class value")
      expect(test.classFn()).toEqual("class")
      expect(test.moduleKey).toBeUndefined()
      expect(test.moduleFn).toBeUndefined()
      Helpers.include(TestClass, Module)
      test = new TestClass()
      expect(test.classKey).toEqual("class value")
      expect(test.classFn()).toEqual("class")
      expect(test.moduleKey).toBeDefined()
      expect(test.moduleFn).toBeDefined()
      expect(test.moduleKey).toEqual("module value")
      expect(test.moduleFn()).toEqual("module")

  describe "#keyOf", ->
    event = null
    beforeEach ->
      event = { type: "keydown" }

    ait "returns function keys on keydown", required, (Helpers) ->
      event.which = 111
      expect(Helpers.keyOf(event)).toEqual("o")
      event.which = 112
      expect(Helpers.keyOf(event)).toEqual("f1")
      event.which = 123
      expect(Helpers.keyOf(event)).toEqual("f12")
      event.which = 124
      expect(Helpers.keyOf(event)).toEqual("|")
    ait "returns non function keys when not keydown", required, (Helpers) ->
      event.type = "keypress"
      event.which = 112
      expect(Helpers.keyOf(event)).toNotBe("f1")
      event.which = 123
      expect(Helpers.keyOf(event)).toNotBe("f12")
    ait "returns defined special keys", required, (Helpers) ->
      event.which = 13
      expect(Helpers.keyOf(event)).toEqual("enter")
      event.which = 39
      expect(Helpers.keyOf(event)).toEqual("right")
      event.which = 46
      expect(Helpers.keyOf(event)).toEqual("delete")

  describe "#pass", ->
    ait "passes arguments through", required, (Helpers) ->
      sum = (one, two, three) -> one + two + three
      boundSum = Helpers.pass(sum, [1, 2, 3], this)
      expect(boundSum()).toEqual(6)
    ait "binds properly", required, (Helpers) ->
      sum = (one, two) -> one + two + this.three
      obj = { three: 3 }
      boundSum = Helpers.pass(sum, [1, 2], obj)
      expect(boundSum()).toEqual(6)

  describe "#capitalize", ->
    ait "capializes the first letter of each word", required, (Helpers) ->
      string = "this Is a test 1 1a = =a"
      expect(Helpers.capitalize(string)).toEqual("This Is A Test 1 1a = =A")
