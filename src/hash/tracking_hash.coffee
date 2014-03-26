#= require ./hash
class Batman.TrackingHash extends Batman.Hash

  constructor: (obj) ->
    @_dirtyKeys = new Batman.Hash
    @_dirtiedKeys = new Batman.Set
    @resetTracking(obj)
    @noTracking = false
    super(obj)

  _markAsDirty: (key) ->
    return if @noTracking
    if !@get('dirtyKeys').hasKey(key)
      cleanValue = @originalValues.get(key)
      @get('dirtyKeys').set(key, cleanValue)
    @get('dirtiedKeys').add(key)
    @set('isDirty', true)

  _markAsClean: (key) ->
    @get('dirtyKeys').unset(key)
    @get('dirtiedKeys').remove(key)
    @set('isDirty', false)

  resetTracking: (obj) ->
    obj ?= @toObject()
    @originalValues = new Batman.SimpleHash(obj)
    @_dirtyKeys.clear()
    @_dirtiedKeys.clear()

  @accessor 'isClean', -> !@get('isDirty')
  @accessor 'isDirty',
    get: -> @_isDirty
    set: (k, v) -> @_isDirty = v

  @accessor 'dirtyKeys', -> @_dirtyKeys
  @accessor '_dirtiedKeys', -> @_dirtiedKeys
  @accessor 'dirtiedKeys', -> @_dirtiedKeys

  @defaultAccessor =
    cache: false
    get: Batman.SimpleHash::get

    set: @mutation (key, value) ->
      originalValue = @originalValues.get(key)
      oldResult = Batman.SimpleHash::get.call(this, key)
      result = Batman.SimpleHash::set.call(this, key, value)

      if value != originalValue
        @_markAsDirty(key)
      else if @get('isDirty') and value == originalValue
        @_markAsClean(key)

      if oldResult? and oldResult != result
        @fire('itemsWereChanged', [key], [result], [oldResult])
      else
        @fire('itemsWereAdded', [key], [result])

      result

    unset: @mutation (key) ->
      result = Batman.SimpleHash::unset.call(this, key)
      @fire('itemsWereRemoved', [key], [result]) if result?
      result

  @accessor @defaultAccessor
