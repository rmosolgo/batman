class Batman.Association
  associationType: ''
  isPolymorphic: false
  defaultOptions:
    saveInline: false
    autoload: true
    nestUrl: false
    includeInTransaction: true

  constructor: (@model, @label, options = {}) ->
    defaultOptions =
      namespace: Batman.currentApp
      name: Batman.helpers.camelize(Batman.helpers.singularize(@label))
    @options = Batman.extend defaultOptions, @defaultOptions, options

    if @options.nestUrl
      Batman.developer.error "You must persist the model #{Batman.functionName(@model)} to use the url helpers on an association" if !@model.urlNestsUnder?
      @model.urlNestsUnder Batman.helpers.underscore(@getRelatedModel().get('resourceName'))

    if @options.extend?
      Batman.extend @, @options.extend

    # Setup encoders and accessors for this association.
    encoder =
      encode: if @options.saveInline then @encoder() else false
      decode: @decoder()

    encoderKey = options.encoderKey || @label
    @model.encode encoderKey, encoder

    # The accessor needs reference to this association object, so curry the association info into
    # the getAccessor, which has the model applied as the context.
    association = this
    getAccessor = -> return association.getAccessor.call(this, association, @model, @label)

    @model.accessor @label,
      get: getAccessor
      set: model.defaultAccessor.set
      unset: model.defaultAccessor.unset

  getRelatedModel: ->
    scope = @options.namespace or Batman.currentApp
    className = @options.name
    relatedModel = scope?[className]
    Batman.developer.do ->
      if !relatedModel and Batman.env isnt 'test'
        namespaceMsg = if @options?.namespace
            "#{@options.namespace}."
          else
            "Batman.currentApp. Is your app running with `MyApp.run()`?"
        Batman.developer.warn "Related model #{className} wasn't found in namespace #{namespaceMsg}"
    relatedModel

  getFromAttributes: (record) -> record.get("attributes.#{@label}")
  setIntoAttributes: (record, value) -> record.get('attributes').set(@label, value)

  inverse: ->
    if relatedAssocs = @getRelatedModel()._batman.get('associations')
      if @options.inverseOf
        return relatedAssocs.getByLabel(@options.inverseOf)

      inverse = null
      relatedAssocs.forEach (label, assoc) =>
        if assoc.getRelatedModel() is @model
          inverse = assoc
      inverse

  reset: ->
    delete @index
    true
