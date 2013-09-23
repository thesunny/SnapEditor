# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["core/browser", "core/range/range.coordinates.ie7", "core/range/range.coordinates.ie8", "core/range/range.coordinates.ie9", "core/range/range.coordinates.ie10", "core/range/range.coordinates.webkit", "core/range/range.coordinates.gecko1", "core/range/range.coordinates.gecko"], (Browser, IE7Coordinates, IE8Coordinates, IE9Coordinates, IE10Coordinates, WebkitCoordinates, Gecko1Coordinates, GeckoCoordinates) ->
  if Browser.isIE7
    Coordinates = IE7Coordinates
  else if Browser.isIE8
    Coordinates = IE8Coordinates
  else if Browser.isIE9
    Coordinates = IE9Coordinates
  else if Browser.isIE10
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
