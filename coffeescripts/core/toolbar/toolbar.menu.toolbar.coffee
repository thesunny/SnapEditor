# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers", "core/toolbar/toolbar.menu", "core/toolbar/toolbar.menu.dropdown"], ($, Helpers, Menu, Dropdown) ->
  class Toolbar extends Menu
    getMenuTemplate: ->
      """
        <div class="snapeditor_toolbar snapeditor_toolbar_component snapeditor_ignore_deactivate">
          <div class="snapeditor_toolbar_frame">
            <ul></ul>
          </div>
        </div>
      """

    getItemTemplate: ->
      '<li><a href="javascript:void(null);" tabindex="-1"></a></li>'

    getDividerTemplate: ->
      '<li class="snapeditor_toolbar_divider"></li>'

    getCSSKey: ->
      "snapeditor_toolbar"

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
          height: 34px;
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
          width: 26px;
          height: 26px;
          cursor: pointer;
          text-decoration: none;
          outline: none;
          background-image: url(#{@options.editor.imageAsset("snapeditor_toolbar.png")});
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
          height: 34px;
        }
      """

    getSubmenuClass: ->
      Dropdown

    showSubmenu: (submenu, e) ->
      if submenu.isShown()
        # If the submenu is already shown, then hide it.
        submenu.hide(e)
      else
        super(submenu, e)

    buildItem: ($container, button) ->
      title = button.text
      shortcut = @options.editor.actionShortcuts[button.action] if typeof button.action == "string"
      title += " (#{Helpers.displayShortcut(shortcut)})" if shortcut
      $container.
        addClass("snapeditor_toolbar_icon_#{Helpers.camelToSnake(button.cleanName)}").
        attr("title", title).
        attr("data-action", button.cleanName)
