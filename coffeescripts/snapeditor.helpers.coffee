define () ->
  {
    # name must be a String
    # behaviourObject must be an Object
    defBehaviour: (name, behaviourObject) ->
      SnapEditor.behaviours[name] = behaviourObject
  }
