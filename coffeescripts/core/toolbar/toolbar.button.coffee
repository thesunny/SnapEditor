# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
  class Button
    # Options:
    # text - used as the title for the button and the text for submenus when
    #   html is not present
    # html - used for submenus
    # action - a function to execute or a key to SnapEditor.actions (ignored
    #   if items is defined)
    # items - array of SnapEditor.buttons or function that returns an array of
    #   SnapEditor.buttons
    # onInclude - a function to execute when the button is included
    constructor: (@name, options) ->
      @state =
        visible: true
        #selected: false
        #enabled: true
      $.extend(this, options)
      @cleanName = @name.replace(/\./g, "_")
      # If items is an array, change it to a function that returns the array.
      if $.type(@items) == "array"
        items = @items
        @items = -> items

    # Default items.
    items: (e) ->
      []

    # A nicer alias for items().
    getItems: (e) ->
      @items(e)

    # items - array of strings
    appendItems: (items) ->
      oldItems = @items
      @items = (e) -> oldItems(e).concat(items)

    # Default onInclude function.
    onInclude: (e) ->

    # Default onRender function.
    onRender: (e) ->

    render: (api) ->
      @onRender(api: api, button: this)
      if @state.visible
        @getEl().show()
      else
        @getEl().hide()

    setEl: (el) ->
      @$el = $(el)

    getEl: ->
      @$el
