# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "core/toolbar/toolbar.menu"], ($, Menu) ->
  describe "Toolbar.Menu", ->
    menu = null
    beforeEach ->
      class TestMenu extends Menu
        getItemTemplate: -> "<li><a></a></li>"
        getDividerTemplate: -> '<li class="divider"></li>'
        getSubmenuClass: -> TestMenu
        buildItem: ($container, button) ->
          $container.addClass(button.name).attr("title", button.text)

      menu = new TestMenu({}, { editor: $("<div/>") })
      menu.options.editor.win = window
      menu.options.editor.execAction = ->
      menu.$el = $("<div/>")
      menu.$content = $("<ul/>")

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
        expect(-> menu.addItem("fail")).toThrow()

      it "throws an error when there is no text", ->
        expect(-> menu.addItem("noText")).toThrow()

      it "throws an error when there is no action or items", ->
        expect(-> menu.addItem("noAction")).toThrow()

      describe "item", ->
        it "add a divider", ->
          menu.addItem("|")
          expect(menu.$content.find(".divider").length).toEqual(1)

        it "adds an item", ->
          menu.addItem("item")
          $li = menu.$content.find("li")
          expect($li.length).toEqual(1)
          $a = $li.find("a")
          expect($a.hasClass("item")).toBeTruthy()
          expect($a.attr("title")).toEqual(SnapEditor.buttons.item.text)

        it "adds the action", ->
          spyOn(menu.options.editor, "execAction")
          menu.addItem("item")
          e = $.Event("item")
          e.api = menu.options.editor
          menu.options.editor.trigger(e)
          expect(menu.options.editor.execAction).toHaveBeenCalledWith(SnapEditor.buttons.item.action, e)

      describe "menu", ->
        constructed = null
        beforeEach ->
          constructed = false
          class Submenu extends Menu
            constructor: (@button, @options) ->
              constructed = true
            isSubmenu: true
          spyOn(menu, "getSubmenuClass").andReturn(Submenu)

        it "creates a submenu", ->
          menu.addItem("menu")
          expect(constructed).toBeTruthy()

        it "gets the action handler using the submenu", ->
          spyOn(menu, "getActionHandler")
          menu.addItem("menu")
          expect(menu.getActionHandler.mostRecentCall.args.length).toEqual(2)
          expect(menu.getActionHandler.mostRecentCall.args[1]).not.toBeNull()
          expect(menu.getActionHandler.mostRecentCall.args[1].isSubmenu).toBeTruthy()

        it "adds the submenu to the submenus list", ->
          menu.addItem("menu")
          expect(menu.submenus.length).toEqual(1)
