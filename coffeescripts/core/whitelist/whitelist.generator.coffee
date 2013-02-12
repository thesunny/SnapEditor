# This generates the following whitelists given the whtielist:
# * defaults
# * whitelistByLabel
# * whitelistByTag
#
# The values are stored as Whitelist.Objects.
#
# All labels are dereferenced to their objects.
define ["jquery.custom", "core/whitelist/whitelist.object"], ($, WhitelistObject) ->
  class Generator
    constructor: (@whitelist) ->

    getDefaults: ->
      @generateWhitelists() unless @defaults
      return @defaults

    getWhitelistByLabel: ->
      @generateWhitelists() unless @whitelistByLabel
      return @whitelistByLabel

    getWhitelistByTag: ->
      @generateWhitelists() unless @whitelistByTag
      return @whitelistByTag

    generateWhitelists: ->
      @all = []
      @defaults = {}
      @whitelistByLabel = {}
      @whitelistByTag = {}
      for label, value of @whitelist
        if @isLabel(label)
          obj = @parse(value)
          @all.push(obj)
          @whitelistByLabel[label] = obj
          # Add to the whitelist by tag.
          @whitelistByTag[obj.tag] = [] unless @whitelistByTag[obj.tag]
          @whitelistByTag[obj.tag].push(obj)
        else
          unless @isLabel(value)
            throw "Whitelist default '#{label}: #{value}' must reference a label"
          @defaults[label] = value
      # Labels that appear as values are not dereferenced above. This is
      # because the dereferenced label may not exist yet. Hence we need to call
      # normalize.
      @normalize()

    # Run through all the whitelists and dereference any labels.
    normalize: ->
      @defaults[label] = @whitelistByLabel[value] for label, value of @defaults
      for obj in @all
        obj.next = @whitelistByLabel[obj.next] if typeof obj.next == "string"

    isLabel: (label) ->
      !!label.match(/^[A-Z0-9]/)

    # Parses the given string into a WhitelistObject.
    # e.g. h1#special-h1.title[data-json, style] > P
    parse: (string) ->
      [element, next] = ($.trim(s) for s in string.split(">"))
      [element, attrs] = ($.trim(s) for s in element.split("["))
      [element, classes...] = ($.trim(s) for s in element.split("."))
      [tag, id] = ($.trim(s) for s in element.split("#"))
      # Handle attributes if there are any.
      # Use [0..-2] to remove the trailing ']'.
      attrs = ($.trim(s) for s in attrs[0..-2].split(",")) if attrs
      next = @parse(next) if next and !@isLabel(next)
      return new WhitelistObject(tag, id, classes, attrs, next)

  return Generator
