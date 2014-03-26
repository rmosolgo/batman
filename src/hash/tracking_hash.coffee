#= require ./hash
class Batman.TrackingHash extends Batman.Hash

  constructor: (obj) ->
    @originalValues = new Batman.SimpleHash
    @resetTracking(obj)
    super(obj)
    @noTracking = false

  _markAsDirty: (key) ->
    return if @noTracking
    if !@get('dirtyKeys').hasKey(key)
      cleanValue = @originalValues.get(key)
      @get('dirtyKeys').set(key, cleanValue)
    @get('dirtiedKeys').add(key)

  _markAsClean: (key) ->
    return if @noTracking
    @get('dirtyKeys').unset(key)
    @get('dirtiedKeys').remove(key)

  resetTracking: (obj) ->
    newCleanValues = Batman.mixin({}, @toObject(), obj)
    @originalValues.replace(newCleanValues)
    @get('dirtiedKeys').clear()
    @get('dirtyKeys').clear()

  @accessor 'isClean', -> !@get('isDirty')
  @accessor 'isDirty',
    cache: false
    get: -> !!@get('dirtiedKeys').length

  @accessor 'dirtyKeys', -> @_dirtyKeys ||= new Batman.SimpleHash
  @accessor '_dirtiedKeys', -> @get('dirtiedKeys')
  @accessor 'dirtiedKeys', -> @_dirtiedKeys ||= new Batman.SimpleSet

  @defaultAccessor =
    cache: false
    get: Batman.SimpleHash::get

    set: @mutation (key, value) ->
      originalValue = @originalValues.get(key)
      oldResult = Batman.SimpleHash::get.call(this, key)
      result = Batman.SimpleHash::set.call(this, key, value)

      if value != originalValue
        @_markAsDirty(key)
      else if value == originalValue
        @_markAsClean(key)

      if oldResult? and oldResult != result
        @fire('itemsWereChanged', [key], [result], [oldResult])
      else
        @fire('itemsWereAdded', [key], [result])

      result

    unset: @mutation (key) ->
      @_markAsDirty(key)
      result = Batman.SimpleHash::unset.call(this, key)
      @fire('itemsWereRemoved', [key], [result]) if result?
      result

  @accessor @defaultAccessor
