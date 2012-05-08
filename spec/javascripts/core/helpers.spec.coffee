require ["core/helpers"], (Helpers) ->
  describe "helpers", ->
    describe "#isElement", ->
      it "returns true for an element", ->
        el = document.createElement("div")
        expect(Helpers.isElement(el)).toBeTruthy()
      it "returns false for a text node", ->
        text = document.createTextNode("This is text")
        expect(Helpers.isElement(text)).toBeFalsy()

    describe "#isTextnode", ->
      it "returns true for a text node", ->
        text = document.createTextNode("This is text")
        expect(Helpers.isTextnode(text)).toBeTruthy()
      it "returns false for an element", ->
        el = document.createElement("div")
        expect(Helpers.isTextnode(el)).toBeFalsy()

    describe "#isBlock", ->
      $editable = null
      beforeEach ->
        $editable = addEditableFixture()

      afterEach ->
        $editable.remove()

      it "returns true when a block element is given", ->
        expect(Helpers.isBlock($("<div/>").appendTo($editable)[0])).toBeTruthy()

      it "returns false when an line element is given", ->
        expect(Helpers.isBlock($("<span/>").appendTo($editable)[0])).toBeFalsy()

      it "returns false if a textnode is given", ->
        text = document.createTextNode("test")
        $editable[0].appendChild(text)
        expect(Helpers.isBlock(text)).toBeFalsy()

    describe "#typeOf", ->
      it "returns boolean", ->
        expect(Helpers.typeOf(true)).toEqual("boolean")
        expect(Helpers.typeOf(false)).toEqual("boolean")
      it "returns number", ->
        expect(Helpers.typeOf(1)).toEqual("number")
        expect(Helpers.typeOf(-1)).toEqual("number")
        expect(Helpers.typeOf(0)).toEqual("number")
        expect(Helpers.typeOf(1.233)).toEqual("number")
      it "returns string", ->
        expect(Helpers.typeOf("")).toEqual("string")
        expect(Helpers.typeOf("test")).toEqual("string")
      it "returns function", ->
        expect(Helpers.typeOf(->)).toEqual("function")
        expect(Helpers.typeOf(Helpers.typeOf)).toEqual("function")
      it "returns array", ->
        expect(Helpers.typeOf([])).toEqual("array")
        expect(Helpers.typeOf([1, 2, 3])).toEqual("array")
      it "returns date", ->
        expect(Helpers.typeOf(new Date())).toEqual("date")
      it "returns regexp", ->
        expect(Helpers.typeOf(/a/)).toEqual("regexp")
      it "returns element", ->
        el = document.createElement("div")
        expect(Helpers.typeOf(el)).toEqual("element")
      it "returns textnode", ->
        el = document.createTextNode("This is text")
        expect(Helpers.typeOf(el)).toEqual("textnode")
      it "returns window", ->
        expect(Helpers.typeOf(window)).toEqual("window")
      it "returns object", ->
        expect(Helpers.typeOf({})).toEqual("object")

    describe "#extend", ->
      it "extends all the methods", ->
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
      it "includes all the methods", ->
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

    describe "#delegate", ->
      it "throws an error if the function is defined", ->
        object = delFn1: ->
        expect(-> Helpers.delegate(object, "delObject", "delFn1")).toThrow()

      it "throws an error if the delegate does not exist", ->
        object = {}
        expect(-> Helpers.delegate(object, "doesNotExist", "delFn1")).toThrow()

      it "delegates the functions to the delegate object", ->
        delFn1Value = delFn2Value = false
        object =
          delObject:
            delFn1: -> delFn1Value = true
            delFn2: -> delFn2Value = true
        Helpers.delegate(object, "delObject", "delFn1", "delFn2")
        object.delFn1()
        expect(delFn1Value).toBeTruthy()
        object.delFn2()
        expect(delFn2Value).toBeTruthy()

      it "delegates the functions to the delegate function", ->
        delFn1Value = false
        object = delFn: -> delFn1: -> delFn1Value = true
        Helpers.delegate(object, "delFn()", "delFn1")
        object.delFn1()
        expect(delFn1Value).toBeTruthy()

      it "passes arguments through", ->
        arg1 = false
        arg2 = ""
        object = delObject: delFn: (a, b) -> arg1 = a and arg2 = b
        Helpers.delegate(object, "delObject", "delFn")
        object.delFn(true, "passed")
        expect(arg1).toBeTruthy()
        expect(arg2).toEqual("passed")

      it "binds the delegate function to the object", ->
        object =
          value: false
          delFn: ->
            @value = true
            return delFn1: ->
        Helpers.delegate(object, "delFn()", "delFn1")
        object.delFn1()
        expect(object.value).toBeTruthy()

      it "binds the delegated function to the delegate object", ->
        object =
          delObject:
            value: false
            delFn1: -> @value = true
        Helpers.delegate(object, "delObject", "delFn1")
        object.delFn1()
        expect(object.delObject.value).toBeTruthy()

    describe "#keyOf", ->
      event = null
      beforeEach ->
        event = { type: "keydown" }

      it "returns function keys on keydown", ->
        event.which = 111
        expect(Helpers.keyOf(event)).toEqual("o")
        event.which = 112
        expect(Helpers.keyOf(event)).toEqual("f1")
        event.which = 123
        expect(Helpers.keyOf(event)).toEqual("f12")
        event.which = 124
        expect(Helpers.keyOf(event)).toEqual("|")
      it "returns non function keys when not keydown", ->
        event.type = "keypress"
        event.which = 112
        expect(Helpers.keyOf(event)).toNotBe("f1")
        event.which = 123
        expect(Helpers.keyOf(event)).toNotBe("f12")
      it "returns defined special keys", ->
        event.which = 13
        expect(Helpers.keyOf(event)).toEqual("enter")
        event.which = 39
        expect(Helpers.keyOf(event)).toEqual("right")
        event.which = 46
        expect(Helpers.keyOf(event)).toEqual("delete")

    describe "#pass", ->
      it "passes arguments through", ->
        sum = (one, two, three) -> one + two + three
        boundSum = Helpers.pass(sum, [1, 2, 3], this)
        expect(boundSum()).toEqual(6)
      it "binds properly", ->
        sum = (one, two) -> one + two + this.three
        obj = { three: 3 }
        boundSum = Helpers.pass(sum, [1, 2], obj)
        expect(boundSum()).toEqual(6)

    describe "#capitalize", ->
      it "capializes the first letter of each word", ->
        string = "this Is a test 1 1a = =a"
        expect(Helpers.capitalize(string)).toEqual("This Is A Test 1 1a = =A")
