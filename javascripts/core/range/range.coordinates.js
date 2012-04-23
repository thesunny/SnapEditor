
define(["core/browser", "core/range/range.coordinates.ie7", "core/range/range.coordinates.ie8", "core/range/range.coordinates.ie9", "core/range/range.coordinates.webkit", "core/range/range.coordinates.gecko1", "core/range/range.coordinates.gecko"], function(Browser, IE7Coordinates, IE8Coordinates, IE9Coordinates, WebkitCoordinates, Gecko1Coordinates, GeckoCoordinates) {
  var Coordinates;
  if (Browser.isIE7) {
    Coordinates = IE7Coordinates;
  } else if (Browser.isIE8) {
    Coordinates = IE8Coordinates;
  } else if (Browser.isIE9) {
    Coordinates = IE9Coordinates;
  } else if (Browser.isWebkit) {
    Coordinates = WebkitCoordinates;
  } else if (Browser.isGecko1) {
    Coordinates = Gecko1Coordinates;
  } else if (Browser.isGecko) {
    Coordinates = GeckoCoordinates;
  } else {
    throw "Your browser is not currently supported.";
  }
  return Coordinates;
});
