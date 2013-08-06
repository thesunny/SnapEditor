define ["jquery.custom", "core/dialog/dialog"], ($, Dialog) ->
  class DialogsManager
    constructor: ->
      @dialogs = {}

    # The first argument is the type.
    # The second argument is a SnapEditor event object
    # All other arguments are user-defined.
    showDialog: ->
      type = arguments[0]
      event = arguments[1]
      args = [].slice.apply(arguments, [2])
      @getDialog(type).open(event, args)

    getDialog: (type) ->
      @dialogs[type] or= new Dialog(type)
