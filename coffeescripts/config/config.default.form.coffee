define ["config/config.default"], (Defaults) ->
  return {
    build: ->
      Defaults.build()
  }
