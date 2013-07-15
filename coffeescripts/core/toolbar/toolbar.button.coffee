define ["jquery.custom"], ($) ->
  class Button
    # Options:
    # text - used as the title for the button and the text for submenus when
    #   html is not present
    # html - used for submenus
    # action - a function to execute or a key to SnapEditor.actions (ignored
    #   if items is defined)
    # items - array of SnapEditor.buttons
    # onInclude - a function to execute when the button is included
    # onOpen - a function to execute when the button is opened
    constructor: (@name, options) ->
      $.extend(this, options)
      @items = @items.slice(0) if @items

    # items - array of strings
    addItems: (items) ->
      @items.concat(items)
