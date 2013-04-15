require ["jquery.custom", "core/toolbar/toolbar.builder"], ($, Builder) ->
  describe "Toolbar.Builder", ->
    $content = options = null
    beforeEach ->
      $content = $("<ul/>")
      class Menu
      options =
        api: $("<div/>")
        templates:
          item: "<li><a></a></li>"
          divider: '<li class="divider"></li>'
        menu:
          class: Menu
        itemBuilder: ($container, item, command) ->
          $container.addClass(item).attr("title", command.text)
      options.api.win = window
      options.api.addKeyboardShortcut = ->

    describe "#addItem", ->
      beforeEach ->
        spyOn(options.api, "addKeyboardShortcut")
        SnapEditor.commands =
            item:
              text: "Item"
              action: ->
              shortcut: "w"
            noText:
              action: ->
              shortcut: "w"
            noAction:
              text: "Test"
              shortcut: "w"
            noShortcut:
              text: "Item"
              action: ->
            menu:
              text: "Menu"
              action: ->
              items: ["1", "2"]

      it "throws an error when the command doesn't exist", ->
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
          expect($a.attr("title")).toEqual(SnapEditor.commands.item.text)

        it "adds the action", ->
          spyOn(SnapEditor.commands.item, "action")
          Builder.addItem($content, "item", options)
          e = $.Event("item")
          e.api = options.api
          options.api.trigger(e)
          expect(SnapEditor.commands.item.action).toHaveBeenCalled()

        it "adds the keyboard shortcut", ->
          Builder.addItem($content, "item", options)
          expect(options.api.addKeyboardShortcut).toHaveBeenCalled()

        it "doesn't add the keyboard shortut when none is given", ->
          Builder.addItem($content, "noShortcut", options)
          expect(options.api.addKeyboardShortcut).not.toHaveBeenCalled()

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
          spyOn(SnapEditor.commands.menu, "action")
          Builder.addItem($content, "menu", options)
          e = $.Event("menu")
          e.api = options.api
          options.api.trigger(e)
          expect(SnapEditor.commands.menu.action).not.toHaveBeenCalled()
          expect(shown).toBeTruthy()

        it "adds the menu to the content's menu list", ->
          Builder.addItem($content, "menu", options)
          expect($content.menus.length).toEqual(1)
