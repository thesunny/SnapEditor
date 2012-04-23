define ["plugins/snap/snap", "plugins/autoscroll/autoscroll"], (Snap, Autoscroll) ->
  return {
    build: ->
      return {
        plugins: [new Snap(), new Autoscroll()]
      }
  }
