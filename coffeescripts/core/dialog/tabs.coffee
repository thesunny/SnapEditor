# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
  class Tabs
    # Options:
    # tabsClassname - classname for the tabs container
    # tabClassname - classname for a tab
    # contentClassname - classname for the content container
    constructor: (@options = {}) ->
      @contents = [] # [ { title: ..., $el: ... }, ... ]
      @$tabs = [] # [ $tab, ... ]

    add: (contentEl, title) ->
      @contents.push(title: title, $el: $(contentEl))

    clear: ->
      @$tabsContainer.remove() if @$tabsContainer
      @$contentContainer.detach() if @$contentContainer
      @contents = []
      @$tabs = []

    insert: (el) ->
      if @contents.length > 0
        # Create the content container.
        @$contentContainer = $("<div/>").
          addClass(@options.contentClassname or "snapeditor_tabs_content").
          appendTo(el)
        content.$el.hide().appendTo(@$contentContainer) for content in @contents

        # Insert tabs if there is more than 1.
        @insertTabs(@$contentContainer) if @contents.length > 1

        # Select the first tab and show the first content.
        @$tabs[0].addClass("selected") if @$tabs[0]
        @contents[0].$el.show().trigger("show")

    insertTabs: (contentContainer) ->
      $contentContainer = $(contentContainer)
      self = this
      @$tabsContainer = $("<ul/>").
        addClass(@options.tabsClassname or "snapeditor_tabs").
        click((e) ->
          $tab = $(e.target).closest("li")
          if $tab.hasClass(self.options.tabClassname or "snapeditor_tab")
            index = parseInt($tab.attr("data-index"), 10)
            unless self.$tabs[index].hasClass("selected")
              # Unselects all the tabs.
              $tab.removeClass("selected") for $tab in self.$tabs
              # Selects the tab.
              self.$tabs[index].addClass("selected")
              # Hide all the contents.
              content.$el.hide() for content in self.contents
              # Show the content.
              self.contents[index].$el.show().trigger("show")
        ).
        insertBefore($contentContainer)
      $.each(@contents, (index, content) ->
        self.$tabs.push(
          $("<li/>").
            addClass(self.options.tabClassname or "snapeditor_tab").
            attr("data-index", index).
            html("<a href=\"javascript:void(null);\">#{content.title}</a>").
            appendTo(self.$tabsContainer)
        )
      )
