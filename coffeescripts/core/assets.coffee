define [], ->
  class Assets
    constructor: (@path = "/") ->
      # Ensure that the path ends with a "/"
      @path += "/" if @path[@path.length-1] != "/"

    file: (filename) ->
      @path + filename

    image: (filename) ->
      @path + "images/#{filename}"

    stylesheet: (filename) ->
      @path + "stylesheets/#{filename}"

    template: (filename) ->
      @path + "templates/#{filename}"

  return Assets
