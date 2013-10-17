#= require ./storage_adapters/rest_storage2

originalLog = console.log
console.log = (options...) ->
  for option in options
    originalLog.call(console, if option?.valueForBinding then option.valueForBinding() else option)

  return null

class Batman.Query extends Batman.Object
  constructor: (@model, @options = {limit: 0, offset: 0}) ->
    @options.model = @model if @model

  where: (options) ->
    @options.where = options

  distinct: (value) ->
    @options.distinct = if typeof value == 'undefined' then true else !!value

  uniq: (value) ->
    @distinct(value)

  order: (key) ->
    @options.order = key

  group: (key) ->
    @options.group = key

  limit: (amount) ->
    @options.limit = amount

  offset: (amount) ->
    @options.offset = amount

  # bind: ->
  #   dataStore = Batman.currentApp.dataStore
  #   if @model
  #     dataStore.on(@model.resourceName)

  find: ->
    Batman.currentApp.dataStore.query(@options)

  fetch: (callback) ->
    @isFetched = true
    console.log "NEW REQUEST"

    adapter = @model.storageAdapter()

    if @options.limit > 0
      adapter.fetch(@options, callback)
    else
      adapter.fetchAll(@options, callback)

  valueForBinding: ->
    console.count "valueForBinding"
    @fetch() if not @isFetched
    # @bind()
    @find()

  toString: ->
    @valueForBinding() || "Loading..."

class Batman.DataStore
  constructor: ->
    @storage = new Batman.Set
    @byModel = {}

  query: (options) ->
    return @querySingle(options) if options.limit == 1

    if model = options.model
      @modelStorage(model).forEach (id, record) ->
        model.fromRecord(record)

  querySingle: (options) ->
    if options.offset < 0
      return @storage[@storage.length + options.offset]

  modelStorage: (modelClassOrName) ->
    @byModel[if typeof modelClassOrName is 'function' then modelClassOrName.resourceName else modelClassOrName] ||= new Batman.Hash

  record: (model, id, _addedRecords) ->
    modelStorage = @modelStorage(model)
    modelStorage.getOrSet id, ->
      record = new Batman.DataStoreRecord(id, model: model)
      Batman.currentApp.dataStore.storage.add(record)
      _addedRecords?.push(record)
      return record

  populate: (json, modelToForce) ->
    modelStorage = @modelStorage(modelToForce)

    addedRecords = []
    modelStorage._preventMutationEvents =>
      for result in json
        record = @record(modelToForce, result.id, addedRecords)
        record.mixinClean(result)
        record
      return null

    modelStorage.fire('itemsWereAdded', addedRecords.map((record) -> record.id), addedRecords) if addedRecords.length
    modelStorage.fire('change', modelStorage, modelStorage)

class Batman.DataStoreRecord
  constructor: (@id, values) ->
    @_dirtyKeys = []
    @mixinClean(values) if values

  mixinClean: (values) ->
    @noDirtyTracking = true
    @set(key, value) for key, value of values
    @noDirtyTracking = false

  set: (key, value) ->
    @_dirtyKeys.push(key) unless @noDirtyTracking
    @[key] = value

  dirtyKeys: ->
    @_dirtyKeys.unique()
