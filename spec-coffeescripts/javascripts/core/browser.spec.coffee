# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
describe "Browser", ->
  required = ["core/browser"]

  ait "returns true for the right browser", required, (Browser) ->
    p("isIE: #{Browser.isIE}")
    p("isIE7: #{Browser.isIE7}")
    p("isIE8: #{Browser.isIE8}")
    p("isIE9: #{Browser.isIE9}")
    p("isGecko: #{Browser.isGecko}")
    p("isGecko1: #{Browser.isGecko1}")
    p("isWebkit: #{Browser.isWebkit}")
    p("hasW3CRanges: #{Browser.hasW3CRanges}")
