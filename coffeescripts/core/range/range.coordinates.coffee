# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
#
# NOTE:
# All of the browser specific coordinate modules expose one public method which
# is getCoordinates. All of the other methods are private.
#
# NOTE:
# TODO:
# The left and right of the coordinates is not dependable. We may wish to
# have the method only return a top and bottom.
#
# NOTE:
# In some situations, the selection could be in reverse (i.e. bottom to top
# instead of the expected top to bottom) and the code needs to account for
# that.
#
# NOTE:
# One method of getting the bounding box is to insert spans and get the
# coordinates of the span. This is done when we can't get coordinates
# directly off the range.
#
# NOTE:
# When we return coordinates, it is always relative to the document and not
# to the viewport. Sometimes we have to calculate this.
define ["core/browser", "core/range/range.coordinates.ie7", "core/range/range.coordinates.ie8", "core/range/range.coordinates.ie9", "core/range/range.coordinates.ie10", "core/range/range.coordinates.webkit", "core/range/range.coordinates.gecko1", "core/range/range.coordinates.gecko"], (Browser, IE7Coordinates, IE8Coordinates, IE9Coordinates, IE10Coordinates, WebkitCoordinates, Gecko1Coordinates, GeckoCoordinates) ->
  if Browser.isIE7
    Coordinates = IE7Coordinates
  else if Browser.isIE8
    Coordinates = IE8Coordinates
  else if Browser.isIE9
    Coordinates = IE9Coordinates
  else if Browser.isIE10 or Browser.isIE11
    Coordinates = IE10Coordinates
  else if Browser.isWebkit
    Coordinates = WebkitCoordinates
  else if Browser.isGecko1
    Coordinates = Gecko1Coordinates
  else if Browser.isGecko
    Coordinates = GeckoCoordinates
  else
    Coordinates = null
  return Coordinates
