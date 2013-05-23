require ["jquery.custom", "core/toolbar/toolbar.builder"], ($, Builder) ->
  describe "Toolbar.Builder", ->
    $content = options = null
    beforeEach ->
      $content = $("<ul/>")
      class Menu
      options =
        editor: $("<div/>")
        templates:
          item: "<li><a></a></li>"
          divider: '<li class="divider"></li>'
        menu:
          class: Menu
        itemBuilder: ($container, item, button) ->
          $container.addClass(item).attr("title", button.text)
      options.editor.win = window
      options.editor.execAction = ->

    describe "#addItem", ->
      beforeEach ->
        SnapEditor.buttons =
            item:
              text: "Item"
              action: ->
            noText:
              action: ->
            noAction:
              text: "Test"
            noShortcut:
              text: "Item"
              action: ->
            menu:
              text: "Menu"
              action: ->
              items: ["1", "2"]

      it "throws an error when the button doesn't exist", ->
        expect(-> Builder.addItem($content, "fail", options)).toThrow()

      it "throws an error when there is no text", ->
        expect(-> Builder.addItem($content, "noText", options)).toThrow()

      it "throws an error when there is no action or items", ->
        expect(-> Builder.addItem($content, "noAction", options)).toThrow()

      describe "item", ->
        it "add a divider", ->
          Builder.addItem($content, "|", options)
          expect($content.find(".divider").length).toEqual(1)

        it "adds an item", ->
          Builder.addItem($content, "item", options)
          $li = $content.find("li")
          expect($li.length).toEqual(1)
          $a = $li.find("a")
          expect($a.hasClass("item")).toBeTruthy()
          expect($a.attr("title")).toEqual(SnapEditor.buttons.item.text)

        it "adds the action", ->
          spyOn(options.editor, "execAction")
          Builder.addItem($content, "item", options)
          e = $.Event("item")
          e.api = options.editor
          options.editor.trigger(e)
          expect(options.editor.execAction).toHaveBeenCalledWith(SnapEditor.buttons.item.action, e)

      describe "menu", ->
        constructed = shown = null
        beforeEach ->
          constructed = false
          shown = false
          class Menu
            constructor: -> constructed = true
            options: flyOut: false
            $menu: $("<div/>")
            isShown: -> false
            show: -> shown = true
            hide: ->
          options.menu.class = Menu
          $content.menus = []

        it "creates a menu", ->
          Builder.addItem($content, "menu", options)
          expect(constructed).toBeTruthy()

        it "adds its own action", ->
          spyOn(SnapEditor.buttons.menu, "action")
          Builder.addItem($content, "menu", options)
          e = $.Event("menu")
          e.api = options.editor
          options.editor.trigger(e)
          expect(SnapEditor.buttons.menu.action).not.toHaveBeenCalled()
          expect(shown).toBeTruthy()

        it "adds the menu to the content's menu list", ->
          Builder.addItem($content, "menu", options)
          expect($content.menus.length).toEqual(1)
