# This plugin controls how the editor will be activated.
define ["cs!jquery.custom", "cs!core/browser", "cs!core/helpers", "cs!core/events", "cs!plugins/activate/activate.others", "cs!plugins/activate/activate.ie"], ($, Browser, Helpers, Events, Others, IE) ->
  class Activate
    constructor: ->
      # TODO: Figure out what the problems are.
      #if $(@el).css('position') == 'absolute'
        #alert("The editable element is positioned absolute. This causes problems in many browsers and is not recommended.")

    register: (@api) ->
      @addActivateEvents()

    # The implementation of this differs between IE and W3C browsers. 
    #
    # IE requires contentEditable to be set after a mouseup in order to
    # preserve cursor position. At this point, a range will exist.
    #
    # W3C requires contentEditable to be set after a mousedown in order to
    # preserve cusor position. However, at this point, a range does not exist.
    # It exists after a click or mouseup.
    addActivateEvents: ->
      throw "#addActivateEvents() needs to be overridden with a browser specific implementation"

    # Handles after a click has occurred.
    #
    # NOTE: This should trigger making @api.$el editable.
    click: ->
      # TODO: Once it is confirmed that editable does not need to know whether
      # an image was selected, remove this.
      #@api.trigger("click.activate", $(e.target).tagName() == "img")
      @api.trigger("click.activate")

    # Activates the editing session including setting it up if it is the first
    # time.
    activate: ->
      @api.activate()
      @api.on("finish.editor", @finish)

    # Finishes the editing session.
    finish: =>
      @api.off("finish.editor", @finish)
      # TODO: remove this once editable is listening to finish.editor
      #@editable.finish()
      @addActivateEvents()

    # True if el is a link or is inside a link. False otherwise.
    #
    # TODO: Determine if this function should be moved. Maybe to Helpers. If it
    # is moved, it should probably be renamed to something more descriptive
    # because it doesn't just check if el is a link. It checks if it is a link
    # or it is inside a link.
    isLink: (el) ->
      $el = $(el)
      $el.tagName() == 'a' or $el.parent('a').length != 0

  Helpers.include(Activate, if Browser.isIE then IE else Others)

  return Activate
