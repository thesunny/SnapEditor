# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define [], ->
  class Assets
    constructor: (@path = "/") ->
      # Ensure that the path ends with a "/"
      @path += "/" if @path[@path.length-1] != "/"

    file: (filename) ->
      @path + filename

    image: (filename) ->
      @file("images/#{filename}")

    flash: (filename) ->
      @file("flash/#{filename}")

  return Assets
