# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers", "core/toolbar/toolbar.menu", "core/data_action_handler"], ($, Helpers, Menu, DataActionHandler) ->
  class Submenu extends Menu
    # Options:
    # * editor
    # * relEl
    constructor: (button, options) ->
      super(button, options)
      @$relEl = $(@options.relEl)

    getMenuTemplate: ->
      """
        <div class="snapeditor_toolbar_menu snapeditor_toolbar_component snapeditor_ignore_deactivate snapeditor_toolbar_menu_#{Helpers.camelToSnake(@button.cleanName)}">
          <ul></ul>
        </div>
      """

    getItemTemplate: ->
      """
        <li>
          <a href="javascript:void(null);" tabindex="-1">
            <table>
              <tr>
                <td class="snapeditor_toolbar_menu_item"></td>
                <td class="snapeditor_toolbar_menu_shortcut"></td>
                <td class="snapeditor_toolbar_menu_arrow_container"></td>
              </tr>
            </table>
          </a>
        </li>
      """

    getDividerTemplate: ->
      '<li class="snapeditor_toolbar_menu_divider"></li>'

    getCSSKey: ->
      "snapeditor_toolbar_submenu"

    getCSS: ->
      """
        .snapeditor_toolbar_menu {
          position: absolute;
          z-index: #{SnapEditor.zIndexBase + 101};
          width: 300px;
          font-size: 14px;
          font-family: Helvetica, Arial, Verdana, Tahoma, sans-serif;
        }

        .snapeditor_toolbar_menu ul {
          background: #ffffff;
          border: 1px solid #dddddd;
          box-shadow: 0 6px 3px -3px #dddddd;
          list-style: none;
          margin: 0;
          padding: 0;
        }

        .snapeditor_toolbar_menu .snapeditor_toolbar_menu_divider {
          background-color: #dddddd;
          width: 100%;
          height: 1px;
        }

        .snapeditor_toolbar_menu li {
          list-style: none;
          margin: 0;
          padding: 0;
        }

        .snapeditor_toolbar_menu li a {
          color: #1e1e1e;
          display: block;
          margin: 0;
          padding: 6px 5px 6px 12px;
          cursor: pointer;
          text-decoration: none;
          outline: none;
        }

        .snapeditor_toolbar_menu li a:hover {
          background-color: #dce2ef;
        }

        .snapeditor_toolbar_menu table, .snapeditor_toolbar_menu th, .snapeditor_toolbar_menu td {
          border: none;
          margin: 0;
          padding: 0;
        }

        .snapeditor_toolbar_menu table {
          width: 100%;
          margin: 0;
          padding: 0;
        }

        .snapeditor_toolbar_menu_shortcut {
          color: #666666;
          text-align: right;
          width: 100px;
        }

        .snapeditor_toolbar_menu_arrow_container {
          width: 16px;
        }

        .snapeditor_toolbar_menu_arrow {
          background-image: url(#{@options.editor.imageAsset("triangle_right.png")});
          width: 16px;
          height: 16px;
        }
      """

    getStyles: ->
      {}

    getDataActionHandler: ->
      new DataActionHandler(@$el, @options.editor.api, mouseover: true)

    buildItem: ($container, button) ->
      title = button.text
      shortcut = @options.editor.actionShortcuts[button.action] if typeof button.action == "string"
      title += " (#{Helpers.displayShortcut(shortcut)})" if shortcut
      $container.
        attr("title", title).
        attr("data-action", button.cleanName)

      # Handle item.
      $item = $container.find(".snapeditor_toolbar_menu_item")
      if button.html
        $item.html(button.html)
      else
        $item.text(button.text)

      # Handle shortcut.
      if shortcut
        $container.find(".snapeditor_toolbar_menu_shortcut").text(Helpers.displayShortcut(shortcut))

      # Handle submenu.
      if button.getItems(api: @options.editor.api).length > 0
        $container.attr("data-mouseover", true)
        $arrowContainer = $container.find(".snapeditor_toolbar_menu_arrow_container")
        $arrow = $("<div/>").addClass("snapeditor_toolbar_menu_arrow").appendTo($arrowContainer)

    setup: ->
      unless @$el
        super
        @$el.on("mouseover", @mouseover)

    show: =>
      unless @shown
        super
        @resizeToFit()
        @$el.css(@getStyles())
        @options.editor.on(
          "snapeditor.toolbar_final_action": @hide
          "snapeditor.mousedown": @hide
          "snapeditor.document_mousedown": @documentMousedown
        )
      # Prevent the if statement from above from returning false and stopping
      # propagation.
      return true

    hide: =>
      if @shown
        super
        @options.editor.on(
          "snapeditor.toolbar_final_action": @hide
          "snapeditor.mousedown": @hide
          "snapeditor.document_mousedown": @documentMousedown
        )
      # Prevent the if statement from above from returning false and stopping
      # propagation.
      return true

    resizeToFit: ->
      # The content fits so reset to defaults.
      @$content.css(
        height: "auto"
        overflow: "visible"
      )
      winSize = $(window).getSize()
      if @$content.getSize().y > winSize.y
        # Resize the content to fit inside the window and add a scrollbar.
        @$content.css(
          height: winSize.y - 10
          overflow: "auto"
        )

    documentMousedown: (e) =>
      @hide() if $(e.target).closest(".snapeditor_toolbar_component").length == 0
      # Prevent the if statement from above from returning false and stopping
      # propagation.
      return true

    mouseover: (e) =>
      @hideSubmenus() if $(e.target).closest("li").length > 0
      # Prevent the if statement from above from returning false and stopping
      # propagation.
      return true
