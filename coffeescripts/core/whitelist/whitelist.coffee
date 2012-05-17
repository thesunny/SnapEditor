# The objects returned contains the following:
# * tag: tag name
# * classes: an array of classes
# * next: object of what should come after when hitting enter
define ["jquery.custom", "core/helpers", "core/whitelist/whitelist.generator"], ($, Helpers, Generator) ->
  class Whitelist
    constructor: (@whitelist) ->
      @generator = new Generator(@whitelist)
      Helpers.delegate(this, "generator", "getDefaults", "getWhitelistByLabel", "getWhitelistByTag")

    # Returns true if the el is whitelisted. False otherwise.
    allowed: (el) ->
      return !!@match(el)

    # Finds the element that should replace the given el.
    # Returns null if the element is inline and does not have a replacement.
    replacement: (el) ->
      $el = $(el)
      tag = $el.tagName()
      replacement = @getDefaults()[tag]
      replacement = @getWhitelistByTag()[tag][0] if !replacement and @getWhitelistByTag()[tag]
      unless replacement
        if Helpers.isBlock($el[0])
          replacement = @getDefaults()["*"]
          throw "The whitelist is missing a '*' default" unless replacement
        else
          replacement = null
      return replacement and replacement.getElement()

    # Finds the element that should be after the given el.
    next: (el) ->
      next = @getDefaults()["*"]
      match = @match(el)
      next = match.next if match and match.next
      return next.getElement()

    # Finds the object that matches the given el or else returns null.
    match: (el) ->
      $el = $(el)
      classes = ($el.attr("class") or "").split(" ").sort()
      match = null
      list = @getWhitelistByTag()[$el.tagName()]
      if list
        for obj in list
          if classes.toString() == obj.classes.toString()
            match = obj
            break
      return match
