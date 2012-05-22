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
      replacement = @getDefaults()[tag] or null
      replacement = @getReplacementFromWhitelistByTag(tag) unless replacement
      return replacement and replacement.getElement(el)

    # Finds the element that should be after the given el.
    next: (el) ->
      next = @getDefaults()["*"]
      throw "The whitelist is missing a '*' default" unless next
      match = @match(el)
      next = match.next if match and match.next
      return next.getElement()

    # Finds the object that matches the given el or else returns null.
    match: (el) ->
      match = null
      list = @getWhitelistByTag()[$(el).tagName()]
      if list
        for obj in list
          if obj.matches(el)
            match = obj
            break
      return match

    # Finds the first object without an id.
    # Returns null if no object can be found.
    getReplacementFromWhitelistByTag: (tag) ->
      list = @getWhitelistByTag()[tag]
      return null unless list
      replacement = null
      for obj in list
        unless obj.id
          replacement = obj
          break
      return replacement
