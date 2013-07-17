#= require ./property
#= require ./keypath

# Batman.Observable is a generic mixin that can be applied to any object to allow it to be bound to.
# It is applied by default to every instance of `Batman.Object` and subclasses.
Batman.Observable =
  isObservable: true

  hasProperty: (key) ->
    @_batman?.properties?.hasKey?(key)

  property: (key) ->
    Batman.initializeObject @
    propertyClass = @propertyClass or Batman.Keypath
    properties = @_batman.properties ||= new Batman.SimpleHash
    if properties.objectKey( key )
      return properties.getObject(key) or properties.setObject( key, new propertyClass(this, key ) )
    else
      return properties.getString(key) or properties.setString(key, new propertyClass(this, key))

  get: (key) ->
    @property(key).getValue()

  set: (key, val) ->
    @property(key).setValue(val)

  unset: (key) ->
    @property(key).unsetValue()

  getOrSet: Batman.SimpleHash::getOrSet

  # `forget` removes an observer from an object. If the callback is passed in,
  # its removed. If no callback but a key is passed in, all the observers on
  # that key are removed. If no key is passed in, all observers are removed.
  forget: (key, observer) ->
    if key
      @property(key).forget(observer)
    else
      @_batman.properties?.forEach (key, property) -> property.forget()

    return this

  # `observe` takes a key and a callback. Whenever the value for that key changes, your
  # callback will be called in the context of the original object.
  observe: (key, handler, options) ->
    @property(key).observe(handler, options)
    return this

  observeAndFire: (key, handler) ->
    Batman.developer.deprecated("observeAndFire", "Please use observe(#{key}, fireImmediately: true, handler) instead.")
    @observe(key, handler, fireImmediately: true)

  observeOnce: (key, handler) ->
    Batman.developer.deprecated("observeOnce", "Please use observe(#{key}, once: true, handler) instead.")
    @observe(key, handler, once: true)
