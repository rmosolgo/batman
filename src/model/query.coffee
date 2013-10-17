#= require ./storage_adapters/rest_storage2

originalLog = console.log
console.log = (options...) ->
  for option in options
    originalLog.call(console, if option?.valueForBinding then option.valueForBinding() else option)

  return null

class Batman.Query extends Batman.Object
  constructor: (@model, @options = {limit: 0, offset: 0}) ->

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

  find: ->
    Batman.DataStore.forModel(@model).query(@options)

  fetch: (callback) ->
    @isFetched = true
    # new Batman.Request options, callback
    console.log "NEW REQUEST"

    adapter = @model.storageAdapter()

    if @options.limit > 0
      adapter.fetch(@options, callback)
    else
      adapter.fetchAll(@options, callback)

  valueForBinding: ->
    @fetch() if not @isFetched
    @find()

  toString: ->
    @valueForBinding() || "Loading..."

class Batman.DataStore extends Batman.Hash
  @forModel: (modelClass) ->
    @stores ||= {}
    @stores[modelClass.storageKey] ||= new Batman.DataStore(modelClass)

  constructor: (@modelClass) ->
    super()

  query: (options) ->
    return @querySingle(options) if options.limit == 1

    for id in @keys()
      @modelClass.fromRecord(@get(id))

  querySingle: (options) ->
    if options.offset < 0
      return @storage[@storage.length + options.offset]

  record: (id) ->
    record = @getOrSet id, =>
      new Batman.DataStoreRecord(this, id)

    return record

  populate: (json) ->
    for result in json
      record = @record(result.id)
      record.mixinClean(result)
      record

class Batman.DataStoreRecord extends Batman.Hash
  constructor: (@dataStore, @id) ->
    super()
    @dirtyKeys = []

  mixinClean: (values) ->
    @noDirtyTracking = true
    @mixin(values)
    @noDirtyTracking = false

  set: (key, value) ->
    @dirtyKeys.push(key) unless @noDirtyTracking
    super

  # fetch: ->
  #   @dataStore.fetchRecord(@id)

  # commit: (values) ->
  #   @mixin(values)
