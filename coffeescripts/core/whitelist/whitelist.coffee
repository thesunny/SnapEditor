# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
#
# This Whitelist object is a container for the Whitelists object which itself
# contains a bunch of WhitelistObject objects. It has a few methods that are
# used by the normalizer.
#
# * isAllowed: Returns true if the element should be allowed in the document
#   at all.
# * getReplacement: 
#
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

    # A general rule is a rule that applies to all rules of a given set of tags.
    # This is used because we don't want to specify the same rule over and
    # over again for each individual whitelist object. For example, all p tags
    # are similar, but if a user specifies p.fancy, he shouldn't have to
    # specify all the other p rules with it.
    addGeneralRule: (rule, tags) ->
      @whitelists.addGeneralRule(rule, tags)

    # Get the default element for the given key.
    getDefaultFor: (key, doc) ->
      def = @whitelists.getByDefault(key)
      def and def.createSafeElementFromElement(doc)

    # MAIN PUBLIC:
    # Returns true if the el is whitelisted. False otherwise.
    isAllowed: (el) ->
      return !!@match(el)

    # MAIN PUBLIC:
    # Finds the element that should replace the given el.
    # Returns null if the element is inline and does not have a replacement.
    getReplacement: (el) ->
      $el = $(el)
      tag = $el.tagName()
      whitelistObject = @whitelists.getByDefault(tag) or null
      whitelistObject = @getReplacementByTag(tag) unless whitelistObject
      whitelistObject = @whitelists.getByDefault("*") if !whitelistObject and Helpers.isBlock(el)
      return whitelistObject and whitelistObject.createSafeElementFromElement(Helpers.getDocument(el), el)

    # MAIN PUBLIC:
    # Finds the element that should be after the given el after the user
    # presses enter.
    getNext: (el) ->
      defaultWhitelistObject = @whitelists.getByDefault("*")
      throw "The whitelist is missing a '*' default" unless defaultWhitelistObject
      match = @match(el)
      # Find the matching next WhitelistObject. In case there is no match,
      # keep the default.
      nextWhitelistObject = if match and match.next     
        @whitelists.match(match.next)
      else
        defaultWhitelistObject 
      return nextWhitelistObject.createSafeElementFromElement(Helpers.getDocument(el))

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
