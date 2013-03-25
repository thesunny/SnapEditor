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
        @$menu.css(@getStyles(@options.flyOut)).show()
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

    getStyles: (flyOut) ->
      relCoords = @$relEl.getCoordinates(true)
      if flyOut
        styles = @getFlyOutStyles()
      else
        styles = @getDropDownStyles()
      styles

    # The entire idea here is that we don't want to cover the button. Hence,
    # we try to position below, above, right then left.
    getDropDownStyles: () ->
      relCoords = @$relEl.getCoordinates(true)
      menuSize = @$menu.getSize(true, true)
      windowBoundary = Helpers.getWindowBoundary()

      fitsVertically = true
      styles = {}
      # Fit vertically first.
      if relCoords.bottom + menuSize.y <= windowBoundary.bottom
        # Fits below.
        styles.top = relCoords.bottom
      else
        # Doesn't fit below.
        if relCoords.top - menuSize.y >= windowBoundary.top
          # Fits above.
          styles.top = relCoords.top - menuSize.y
        else
          # Doesn't fit above.
          styles.top = windowBoundary.top
          fitsVertically = false
      # Then fit horizontally.
      if fitsVertically
        # If the dropdown fits vertically, align the left side of the submenu
        # with the left side of the button, or align the right side of the
        # submenu with the right side of the window.
        left = relCoords.left
        right = windowBoundary.right
      else
        # If the dropdown doesn't fit vertically, align the left side of the
        # submenu with the right side of the button, or align the right side
        # of the submenu with the left side of the button.
        left = relCoords.right
        right = relCoords.left

      if left + menuSize.x <= windowBoundary.right
        # Fits to the right.
        styles.left = left
      else
        # Doesn't fit to the right.
        # We ignore it if it doesn't fit to the left because that's just
        # ridiculous.
        styles.left = right - menuSize.x

      styles

    # The entire idea here is to try to show the entire flyout to the right,
    # then left, while keeping it vertically in view.
    getFlyOutStyles: ->
      relCoords = @$relEl.getCoordinates(true)
      menuSize = @$menu.getSize(true, true)
      windowSize = $(window).getSize()
      windowScroll = $(window).getScroll()
      windowBoundary = Helpers.getWindowBoundary()

      styles = {}
      # Fit horizontally first.
      if relCoords.right + menuSize.x <= windowBoundary.right
        # Fits to the right.
        styles.left = relCoords.right
      else
        # Doesn't fit to the right.
        styles.left = relCoords.left - menuSize.x
      # Then fit vertically.
      if relCoords.top + menuSize.y <= windowBoundary.bottom
        # Fits below.
        styles.top = relCoords.top
      else
        # Doesn't fit below.
        if relCoords.bottom - menuSize.y >= windowBoundary.top
          # Fits above.
          styles.top = relCoords.bottom - menuSize.y
        else
          # Doesn't fit above.
          styles.top = windowBoundary.top

      styles
