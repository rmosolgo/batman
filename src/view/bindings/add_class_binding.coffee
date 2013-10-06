#= require ./abstract_attribute_binding

redundantWhitespaceRegex = /[ \t]{2,}/g

class Batman.DOM.AddClassBinding extends Batman.DOM.AbstractAttributeBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    {@invert} = definition

    @classes = for name in definition.attr.split('|')
      {name: name, pattern: new RegExp("(?:^|\\s)#{name}(?:$|\\s)", 'i')}

    @finalized = false

    super

  dataChange: (value) ->
    currentName = @node.className

    for {name, pattern} in @classes
      includesClassName = pattern.test(currentName)
      if !!value is !@invert
        if !includesClassName
          if @finalized
            currentName = "#{currentName} #{name}"
          else
            @addName = name
      else
        if includesClassName
          if @finalized
            currentName = currentName.replace(pattern, ' ')
          else
            @removePattern = pattern

    @node.className = currentName.trim().replace(redundantWhitespaceRegex, ' ')
    true

  @finalize: (node, bindings) ->
    currentName = node.className
    addNames = {}
    removePatterns = {}

    for binding in bindings
      if binding.addName
        addNames[binding.addName] = binding.addName
        binding.addName = null

      if binding.removePattern
        removePatterns[binding.removePattern] = binding.removePattern
        binding.removePattern = null

    for [_, name] in addNames
      currentName = "#{currentName} #{name}"

    for [_, pattern] in removePatterns
      currentName.replace(pattern, ' ')

    node.className = currentName.trim().replace(redundantWhitespaceRegex, ' ')

    @finalized = true
