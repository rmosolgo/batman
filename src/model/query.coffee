#= require ./storage_adapters/rest_storage2

originalLog = console.log
console.log = (options...) ->
  for option in options
    originalLog.call(console, if option?.valueForBinding then option.valueForBinding() else option)

  return null

class Batman.Query extends Batman.Object
  constructor: (model, @options = {limit: 0, offset: 0}) ->
    @options.model = model if model

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

  _isSingleRecord: ->
    @options.id? or @options.limit == 1

  find: ->
    if @_isSingleRecord()
      record = Batman.currentApp.dataStore.querySingle(@options)
      return @options.model.fromRecord(record) if record
    else
      records = Batman.currentApp.dataStore.query(@options)
      for record in records
        @options.model.fromRecord(record) if record

  fetch: (callback) ->
    @isFetched = true

    adapter = @options.model.storageAdapter()

    if @_isSingleRecord()
      adapter.fetch(@options, callback)
    else
      adapter.fetchAll(@options, callback)

  valueForBinding: ->
    console.count "valueForBinding"
    @fetch() if not @isFetched
    @find()

  toString: ->
    @valueForBinding() || "Loading..."

class Batman.DataStore
  constructor: ->
    @storage = new Batman.Set
    @byModel = {}

  query: (options) ->
    if model = options.model
      @modelStorage(model).forEach (id, record) ->
        record

  querySingle: (options) ->
    if options.id?
      return @modelStorage(options.model).get(options.id)

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

  populate: (model, json) ->
    modelStorage = @modelStorage(model)

    addedRecords = []
    changedRecords = []

    buildRecord = (data) =>
      record = @record(model, data.id, addedRecords)
      record.mixinClean(data)
      changedRecords.push(record)

    modelStorage._preventMutationEvents ->
      if Batman.typeOf(json) is 'Array'
        for data in json
          buildRecord(data)
      else
        buildRecord(json)

      return null

    modelStorage.fire('itemsWereAdded', addedRecords.map((record) -> record.id), addedRecords) if addedRecords.length
    modelStorage.fire('change', modelStorage, modelStorage)

    return changedRecords

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
