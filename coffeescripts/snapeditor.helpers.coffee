define () ->
  {
    # name must be a String
    # behaviourObject must be an Object
    defBehaviour: (name, behaviourObject) ->
      SnapEditor.behaviours[name] = behaviourObject

    defActions: (actions) ->
      for own key, value of actions
        SnapEditor.actions[key] = value

    defAction: (name, value) ->
      SnapEditor.actions[name] = value

    defButtons: (actions) ->
      for own key, value of actions
        SnapEditor.buttons[key] = value

    defButton: (name, value) ->
      SnapEditor.buttons[name] = value
  }
