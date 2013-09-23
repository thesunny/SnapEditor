# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers", "core/browser"], ($, Helpers, Browser) ->
  class WhitelistObject
    # Arguments:
    # * tag - the tagname of the element
    # * id - the id of the element
    # * classes - an array of classnames
    # * attrs - an array of allowed attribute names
    # * values - object { attr1: [val1, val2] }
    # * next - the whitelist object that should be inserted on enter
    constructor: (@tag, @id = null, @classes = [], attrs = [], values = {}, @next) ->
      @classes = @classes.sort().join(" ")
      @attrs = {}
      @attrs[attr] = true for attr in attrs
      @values = {}
      for attr, vals of values
        @values[attr] = {}
        @values[attr][val] = true for val in vals

    # Adds the given classes.
    # classes can either be a space separated string or an array.
    # All duplicates are removed.
    addClasses: (classes) ->
      if classes.length > 0
        @classes += " #{$.makeArray(classes).join(" ")}"
        @classes = Helpers.uniqueArray(@classes.split(" ")).sort().join(" ")

    # Adds the attributes.
    # attrs can either be an array of attributes or an object of the form:
    # { attr1: true, attr2: true }
    # All duplicates are removed
    addAttributes: (attrs) ->
      if $.type(attrs) == "array"
        @attrs[attr] = true for attr in attrs
      else
        $.extend(@attrs, attrs)

    # Adds the object of values.
    # The object can be of either form:
    # { attr1: [value1, value2, value3] }
    # { attr1: { value1: true, value2: true, value3: true } }
    addValues: (values) ->
      for attr, vals of values
        @values[attr] or= {}
        if $.type(vals) == "array"
          @values[attr][val] = true for val in vals
        else
          $.extend(@values[attr], vals)

    # Takes a Whitelist.Object and merges it in with thie one.
    # Only classes, attributes, and values are merged.
    merge: (obj) ->
      @addClasses(obj.classes)
      @addAttributes(obj.attrs)
      @addValues(obj.values)

    # If a template is given, the allowed attributes are copied.
    getElement: (doc, templateEl) ->
      $el = $(doc.createElement(@tag))
      # Add the classes if there are any.
      $el.attr("class", @classes) if @classes.length > 0
      # Copy the allowed attributes over from the template.
      ($el.attr(attr, $(templateEl).attr(attr)) for attr, value of @attrs) if templateEl
      # Remove all styles and copy the allowed values over from the template.
      if templateEl and @values["style"]
        $el.attr("style", "")
        $el.css(value, $(templateEl).css(value)) for value, bool of @values["style"]
      return $el[0]

    # Returns true if the el matches.
    matches: (el) ->
      @tagMatches(el) and @idMatches(el) and @classesMatch(el) and @attributesAllowed(el)

    # Returns true if the tagnames match.
    tagMatches: (el) ->
      $(el).tagName() == @tag

    # Returns true if the ids match.
    idMatches: (el) ->
      id = $(el).attr("id")
      !@id and typeof id == "undefined" or @id == id

    # Returns true if the classes match.
    classesMatch: (el) ->
      ($(el).attr("class") or "").split(" ").sort().join(" ") == @classes

    # Returns true if all the attributes are allowed.
    # Ignores id and class.
    attributesAllowed: (el) ->
      for attr in el.attributes
        continue if @attributeAllowedByDefault(el, attr)
        return false unless @attrs[attr.name]
        # If the values are restricted, make sure they are all allowed.
        return false if @values[attr.name] and !@valuesAllowed(attr.name, attr.value)
      return true

    # If the attribute is an id or class, it is automatically allowed.
    # IE7 loads the attributes array with both user and browser defined
    # attributes. Luckily, there is a specified field which will be false
    # for browser defined attributes which we can skip.
    # IE8 does not load all browser defined attributes. Just some. For
    # example, <a> has a "shape" attribute. We use the same technique.
    # In IE7/8, images, once loaded, have a completed attribute.
    # Unfortunately, attr.specified is true for this attribute even though it
    # is not user defined. Hence, we look for it specifically.
    attributeAllowedByDefault: (el, attr) ->
      attr.name == "id" or attr.name == "class" or ((Browser.isIE7 or Browser.isIE8) and (!attr.specified or ($(el).tagName() == "img" and attr.name == "complete")))

    valuesAllowed: (attr, vals) ->
      if attr == "style"
        values = vals.split(";")
        values = ($.trim(val.split(":")[0]) for val in values)
        for val in values
          return false if val.length > 0 and !@values[attr][val]
        return true
      else
        throw "Whitelist: Values for #{attr} are unsupported. Only values for the style attribute can be checked."
