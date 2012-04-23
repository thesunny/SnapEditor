
define(["core/browser", "core/range/range.w3c", "core/range/range.ie"], function(Browser, W3C, IE) {
  var Module;
  Module = Browser.hasW3CRanges ? W3C : IE;
  return Module;
});
