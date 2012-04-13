define ["cs!core/helpers", "cs!plugins/inline_styler/inline_styler"], (Helpers, InlineStyler) ->
  plugins = {}
  Helpers.extend(plugins, new InlineStyler().getToolbar())
  return plugins
