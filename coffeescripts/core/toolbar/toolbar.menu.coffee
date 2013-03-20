define ["jquery.custom", "core/helpers", "core/toolbar/toolbar.builder", "core/data_action_handler"], ($, Helpers, Builder, DataActionHandler) ->
  class Menu
    # Options:
    # * flyOut: default false
    constructor: (@api, @$relEl, @items, @options = {}) ->
      @setup()

    menuTemplate: """
      <div class="snapeditor_toolbar_menu snapeditor_toolbar_component snapeditor_ignore_deactivate">
        <ul></ul>
      </div>
    """

    itemTemplate: """
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

    dividerTemplate: '<li class="snapeditor_toolbar_menu_divider"></li>'

    getCSS: ->
      """
        .snapeditor_toolbar_menu {
          position: absolute;
          z-index: 201;
          width: 300px;
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
          font-size: 14px;
          color: #1e1e1e;
          display: block;
          margin: 0;
          padding: 5px 5px;
          cursor: pointer;
          text-decoration: none;
          outline: none;
        }

        .snapeditor_toolbar_menu li a:hover {
          background-color: #dce2ef;
        }

        .snapeditor_toolbar_menu table, .snapeditor_toolbar_menu th, .snapeditor_toolbar_menu td {
          border: none;
        }

        .snapeditor_toolbar_menu table {
          width: 100%;
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
          background-image: url(#{@api.imageAsset("triangle_right.png")});
          width: 16px;
          height: 16px;
        }
      """

    setup: ->
      @$menu = Builder.build(@items,
        api: @api
        templates:
          container: @menuTemplate
          item: @itemTemplate
          divider: @dividerTemplate
        menu:
          class: Menu
          options:
            flyOut: true
        itemBuilder: ($container, item, command) ->
          title = command.text
          title += " (#{Helpers.displayShortcut(command.shortcut)})" if command.shortcut
          $container.
            attr("title", title).
            attr("data-action", item)

          # Handle item.
          $item = $container.find(".snapeditor_toolbar_menu_item")
          if command.html
            $item.html(command.html)
          else
            $item.text(command.text)

          # Handle shortcut.
          if command.shortcut
            $shortcut = $container.find(".snapeditor_toolbar_menu_shortcut").text(Helpers.displayShortcut(command.shortcut))

          # Handle submenu.
          if command.items
            $container.attr("data-mouseover", true)
            $arrowContainer = $container.find(".snapeditor_toolbar_menu_arrow_container")
            $arrow = $("<div/>").addClass("snapeditor_toolbar_menu_arrow").appendTo($arrowContainer)
      ).hide().appendTo("body")
      @api.insertStyles("snapeditor_toolbar_menu", @getCSS())
      @dataActionHandler = new DataActionHandler(@$menu, @api, mouseover: true)
      @$menu.on("mouseover", @mouseover)

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

    isShown: ->
      @shown

    show: =>
      unless @shown
        @dataActionHandler.activate()
        @api.on(
          "snapeditor.toolbar_final_action": @hide
          "snapeditor.document_mousedown": @documentMousedown
        )
        coords = @$relEl.getCoordinates(true)
        if @options.flyOut
          style = top: coords.top, left: coords.right
        else
          style = top: coords.bottom, left: coords.left
        @$menu.css(style).show()
        @shown = true
      # Prevent the if statement from above from returning false and stopping
      # propagation.
      return true

    hide: =>
      if @shown
        @api.off(
          "snapeditor.toolbar_final_action": @hide
          "snapeditor.document_mousedown": @documentMousedown
        )
        @hideSubmenus()
        @$menu.hide()
        @shown = false
      # Prevent the if statement from above from returning false and stopping
      # propagation.
      return true

    hideSubmenus: ->
      menu.hide() for menu in @$menu.menus
