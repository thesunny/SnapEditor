# = Toolbar API
#
# == Commands
#
# All buttons are viewed as commands. Commands can be defined in two ways.
# 1. As part of the SnapEditor.commands/internalCommands array.
# 2. As part of the commands array in a plugin of the
#    SnapEditor.plugins/internalPlugins array.
#
# Mandatory keys:
# * text - the title for the button and the text for the menu item if html is
#   not specified
# * action - a function to handle the action (optional if items is specified)
#
# Optional keys:
# * html - html for menu items
# * shortcut - keyboard shortcut with '.' as the delimiter
# * items - array of commands for a submenu
#
# == Buttons/Menu Items
#
# === Classes
#
# The button's class is built from the snake case of the corresponding command.
#   snapeditor_toolbar_icon_<snake case of the command>
#
# The menu's class is built from the snake case of the corresponding command.
#   snapeditor_toolbar_menu_<snake case of the command>
#
# The menu items do not have specific classes because the command developer
# has full control over the HTML inside the menu item.
#
# == Shortcut
#
# When specified, the action function will be triggered when the shortcut is
# pressed.
#
# The shortcut is included in the title in parentheses and modified for
# displaying.
#   shortcut: ctrl.b
#   title: Bold (Ctrl+B)
#
# The shortcut is included in the menu item and modified for displaying.
#   shortcut: ctrl.b
#   menu item: Bold     Ctrl+B
#
# == Action
#
# When buttons and menu items that don't have submenus are clicked, they
# trigger the corresponding action.
#
# The action function has one argument: an action event.
#
# The action event contains access to the SnapEditor API.
#   e.api
#
# == Submenus
#
# To add submenus, specify the items array and populate it with commands.
#   items: ["Bold", "Italic"]
#
# Menu items will automatically have a right triangle to indicate the
# availability of a submenu.
#
# There are no limits to submenus, but we don't recommend more than 2 levels
# deep.
#
# Example
#
# SnapEditor.commands = {
#   style: {
#     text: "Style",
#     items: ["styleInline", "styleBlock"]
#   },
#   styleInline: {
#     text: "Style Inline",
#     html: '<span class="important">Style Inline</span>',
#     items: ["bold", "italic"]
#   },
#   bold: {
#     text: "Bold",
#     shortcut: "ctrl.b",
#     action: function (e) { e.api.bold(); }
#   },
#   italic: {
#     text: "Italic",
#     shortcut: "ctrl.i",
#     action: function (e) { e.api.italic(); }
#   },
#   styleBlock: {
#     text: "Style Block",
#     html: '<span class="important">Style Block</span>',
#     items: ["h1", "h2"]
#   },
#   h1: {
#     text: "H1",
#     shortcut: "ctrl.alt.1",
#     action: function (e) { e.api.h1(); }
#   },
#   h2: {
#     text: "H2",
#     shortcut: "ctrl.alt.2",
#     action: function (e) { e.api.h2(); }
#   }
# };

define ["jquery.custom", "core/helpers", "core/toolbar/toolbar.builder", "core/toolbar/toolbar.menu", "core/data_action_handler"], ($, Helpers, Builder, Menu, DataActionHandler) ->
  class Toolbar
    constructor: (@api) ->

    toolbarTemplate: """
      <div class="snapeditor_toolbar snapeditor_toolbar_component snapeditor_ignore_deactivate">
        <div class="snapeditor_toolbar_frame">
          <ul></ul>
        </div>
      </div>
    """

    itemTemplate: '<li><a href="javascript:void(null);" tabindex="-1"></a></li>'

    dividerTemplate: '<li class="snapeditor_toolbar_divider"></li>'

    getCSS: ->
      """
        .snapeditor_toolbar ul {
          background: #f0f0f0;
          filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#f5f5f5', endColorstr='#e6e6e6');
          background: -webkit-gradient(linear, left top, left bottom, from(#f5f5f5), to(#e6e6e6));
          background: -moz-linear-gradient(top, #f5f5f5, #e6e6e6);
          border: 1px solid #dddddd;
          list-style: none;
          margin: 0;
          padding: 0;
          height: 33px;
        }

        .snapeditor_toolbar li {
          list-style: none;
          margin: 0;
          padding: 3px 1px;
          float: left;
        }

        .snapeditor_toolbar li a {
          display: block;
          border: 1px solid transparent;
          margin: 0;
          padding: 0;
          width: 25px;
          height: 25px;
          cursor: pointer;
          text-decoration: none;
          outline: none;
          background-image: url(#{@api.imageAsset("snapeditor_toolbar.png")});
          background-repeat: no-repeat;
        }

        .snapeditor_toolbar li a:hover {
          background-color: #d0e0f0;
          border-color: #98a8b8;
        }

        .snapeditor_toolbar .snapeditor_toolbar_divider {
          background: #e0e0e0;
          filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#dddddd', endColorstr='#e6e6e6');
          background: -webkit-gradient(linear, left top, left bottom, from(#dddddd), to(#e6e6e6));
          background: -moz-linear-gradient(top,  #dddddd,  #e6e6e6);
          margin: 0;
          padding: 0;
          width: 1px;
          height: 31px;
        }
      """

    setup: ->
      @$toolbar = Builder.build(@api.config.toolbar.items,
        api: @api
        templates:
          container: @toolbarTemplate
          item: @itemTemplate
          divider: @dividerTemplate
        menu:
          class: Menu
        itemBuilder: ($container, item, command) ->
          title = command.text
          title += " (#{Helpers.displayShortcut(command.shortcut)})" if command.shortcut
          $container.
            addClass("snapeditor_toolbar_icon_#{Helpers.camelToSnake(item)}").
            attr("title", title).
            attr("data-action", item)
      )
      @api.insertStyles("snapeditor_toolbar", @getCSS())
      @dataActionHandler = new DataActionHandler(@$toolbar, @api)
