define ["cs!plugins/snap/snap", "cs!plugins/autoscroll/autoscroll"], (Snap, Autoscroll) ->
  return {
    build: ->
      return {
        plugins: [new Snap(), new Autoscroll()]
      }
  }
