# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# This generates the following whitelists given the whtielist:
# * defaults
# * byLabel
# * byTag
#
# The values are stored as Whitelist.Objects.
define ["jquery.custom", "core/helpers", "core/whitelist/whitelist.object"], ($, Helpers, WhitelistObject) ->
  class Whitelists
    constructor: (whitelist) ->
      @defaults = {} # { *: "label", tag: "label" }
      @byLabel = {} # { "label": Whitelist.Object }
      @byTag = {} # { "tag": [Whitelist.Object, Whitelist.Object] }
      @general = {} # { "tag": [Whitelist.Object, Whitelist.Object] }
      @generalStrings = {} # { "tag": ["rule", "rule"] }
      @add(key, rule) for key, rule of whitelist

    # Returns a Whitelist.Object.
    getByDefault: (key) ->
      @byLabel[@defaults[key]]

    # Returns a Whitelist.Object.
    getByLabel: (label) ->
      @byLabel[label]

    # Returns an array of Whitelist.Object.
    getByTag: (tag) ->
      @byTag[tag]

    # Add a rule to the whitelists.
    # key - label, tag, or *
    # rule - whitelist rule
    add: (key, rule) ->
      if @isLabel(key)
        prevObj = @byLabel[key]
        obj = @parse(rule)
        # Add general rules.
        obj.merge(generalObj) for generalObj in @general[obj.tag] or []
        @byLabel[key] = obj
        # Add to the whitelist by tag.
        @byTag[obj.tag] or= []
        @byTag[obj.tag].push(obj)
        # Remove the previous object if there was one.
        @byTag[prevObj.tag].splice($.inArray(prevObj, @byTag[prevObj.tag]), 1) if prevObj
      else
        if @isLabel(rule)
          @defaults[key] = rule
        else
          label = Helpers.capitalize(rule)
          @add(label, rule)
          @defaults[key] = label

    # Adds a general rule that will be applied to all the given tags.
    # rule - whtielist rule
    # tags - an array of tags to attach the rule to
    addGeneralRule: (rule, tags) ->
      obj = @parse(rule)
      for tag in tags
        # Add the new whitelist object if the rule isn't already added.
        @generalStrings[tag] or= []
        if $.inArray(rule, @generalStrings[tag]) == -1
          @generalStrings[tag].push(rule)
          @general[tag] or= []
          @general[tag].push(obj)
          # Add the rule to all existing whitelist objects.
          tagObj.merge(obj) for tagObj in @byTag[tag] or []

    # Finds the whitelist object that matches the given object or else returns
    # null.
    # obj can be an element, a label, or a rule.
    match: (obj) ->
      if Helpers.isElement(obj)
        @matchByElement(obj)
      else if typeof obj == "string"
        if @isLabel(obj)
          @getByLabel(obj) or null
        else
          @matchByRule(obj)
      else
        null

    # Finds the whitelist object that matches the given el or else returns null.
    matchByElement: (el) ->
      match = null
      list = @getByTag($(el).tagName())
      if list
        for obj in list
          if obj.matches(el)
            match = obj
            break
      return match


    # Finds the whitelist object that matches the given rule or else returns
    # null.
    matchByRule: (rule) ->
      # Parse the rule.
      # Then create an element off of the whitelist object.
      # Then find the match.
      @matchByElement(@parse(rule).getElement(document))

    isLabel: (label) ->
      !!label.match(/^[A-Z0-9]/)

    # Parses the given string into a WhitelistObject.
    # e.g. h1#special-h1.title[data-json, style=(background|text-align)] > P
    parse: (rule) ->
      [element, next] = ($.trim(s) for s in rule.split(">"))
      [element, attrs] = ($.trim(s) for s in element.split("["))
      [element, classes...] = ($.trim(s) for s in element.split("."))
      [tag, id] = ($.trim(s) for s in element.split("#"))
      values = {}
      # Handle attributes if there are any.
      # Use [0..-2] to remove the trailing ']'.
      if attrs
        attrs = for s in attrs[0..-2].split(",")
          [attr, v] = $.trim(s).split("=(")
          # Handle values if there are any.
          # Use [0..-2] to remove the trailing ')'.
          values[attr] = ($.trim(s) for s in v[0..-2].split("|")) if v
          attr
      new WhitelistObject(tag, id, classes, attrs, values, next)
