# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# The objects returned contains the following:
# * tag: tag name
# * classes: an array of classes
# * next: object of what should come after when hitting enter
define ["jquery.custom", "core/helpers", "core/whitelist/whitelist.whitelists"], ($, Helpers, Whitelists) ->
  class Whitelist
    constructor: (@whitelist) ->
      @whitelists = new Whitelists(@whitelist)

    # Add a new rule to the whitelist.
    add: ->
      switch arguments.length
        when 1
          throw "Expected a map object" unless $.isPlainObject(arguments[0])
          @add(key, rule) for own key, rule of arguments[0]
        when 2
          @whitelists.add(arguments[0], arguments[1])
        else
          throw "Wrong number of arguments to Whitelist#add"

    addGeneralRule: (rule, tags) ->
      @whitelists.addGeneralRule(rule, tags)

    # Get the default element for the given key.
    getDefaultFor: (key, doc) ->
      def = @whitelists.getByDefault(key)
      def and def.getElement(doc)

    # Returns true if the el is whitelisted. False otherwise.
    isAllowed: (el) ->
      return !!@match(el)

    # Finds the element that should replace the given el.
    # Returns null if the element is inline and does not have a replacement.
    getReplacement: (el) ->
      $el = $(el)
      tag = $el.tagName()
      replacement = @whitelists.getByDefault(tag) or null
      replacement = @getReplacementByTag(tag) unless replacement
      replacement = @whitelists.getByDefault("*") if !replacement and Helpers.isBlock(el)
      return replacement and replacement.getElement(Helpers.getDocument(el), el)

    # Finds the element that should be after the given el.
    getNext: (el) ->
      next = @whitelists.getByDefault("*")
      throw "The whitelist is missing a '*' default" unless next
      match = @match(el)
      # Find the matching next whitelist object. In case there is no match,
      # keep the default.
      next = @whitelists.match(match.next) or next if match and match.next
      return next.getElement(Helpers.getDocument(el))

    # Finds the object that matches the given el or else returns null.
    match: (el) ->
      @whitelists.match(el)

    # Finds the first object without an id.
    # Returns null if no object can be found.
    getReplacementByTag: (tag) ->
      list = @whitelists.getByTag(tag)
      return null unless list
      replacement = null
      for obj in list
        unless obj.id
          replacement = obj
          break
      return replacement
