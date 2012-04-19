define ["cs!plugins/snap/snap", "cs!plugins/autoscroll/autoscroll"], (Snap, Autoscroll) ->
  return {
    plugins: [new Snap(), new Autoscroll()]
  }
