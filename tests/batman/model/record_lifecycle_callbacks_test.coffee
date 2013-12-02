{TestStorageAdapter} = window

QUnit.module "Batman.Model record lifecycle callbacks sequence",
  setup: ->
    @spies = spies =
      counter: 0
      fireSpy: (spyName, otherArg) ->
        @counter += 1
        @["#{spyName}Spy"](@counter, otherArg)

    positions = ['before', 'after']
    actions = ['Create', 'Update', 'Save', 'Destroy', 'Commit']

    for action in actions
      for position in positions
        @spies["#{position}#{action}Spy"] = createSpy()

    class @Product extends Batman.Model
      @encode 'name'
      @persist TestStorageAdapter

      @beforeCreate -> spies.fireSpy('beforeCreate', @constructor.name)
      @afterCreate -> spies.fireSpy('afterCreate', @constructor.name)

      @beforeUpdate -> spies.fireSpy('beforeUpdate', @constructor.name)
      @afterUpdate -> spies.fireSpy('afterUpdate', @constructor.name)

      @beforeSave -> spies.fireSpy('beforeSave', @constructor.name)
      @afterSave -> spies.fireSpy('afterSave', @constructor.name)

      @beforeDestroy -> spies.fireSpy('beforeDestroy', @constructor.name)
      @afterDestroy -> spies.fireSpy('afterDestroy', @constructor.name)

      @beforeCommit -> spies.fireSpy('beforeCommit', @constructor.name)
      @afterCommit -> spies.fireSpy('afterCommit', @constructor.name)

test 'saving a new record fires Create then Save then Commit callbacks', ->
  newProduct = new @Product(name: "Solar-powered Flashlight")
  @spies.counter = 0
  newProduct.save (err, prod) =>
    deepEqual @spies.beforeCreateSpy.lastCallArguments, [1, "Product"], 'beforeCreate was fired and called in the context of the record'
    deepEqual @spies.beforeSaveSpy.lastCallArguments, [2, "Product"],   'beforeSave was fired and called in the context of the record'
    deepEqual @spies.beforeCommitSpy.lastCallArguments, [3, "Product"], 'beforeCommit was fired and called in the context of the record'

    deepEqual @spies.afterCreateSpy.lastCallArguments, [4, "Product"], 'afterCreate was fired and called in the context of the record'
    deepEqual @spies.afterSaveSpy.lastCallArguments, [5, "Product"],   'afterSave was fired and called in the context of the record'
    deepEqual @spies.afterCommitSpy.lastCallArguments, [6, "Product"], 'afterCommit was fired and called in the context of the record'

test 'saving an existing record fires Update then Save then Commit callbacks', ->
  @Product.find 10, (err, product) =>
    @spies.counter = 0
    product.save (err, prod) =>
      deepEqual @spies.beforeUpdateSpy.lastCallArguments, [1, "Product"], 'beforeUpdate was fired and called in the context of the record'
      deepEqual @spies.beforeSaveSpy.lastCallArguments, [2, "Product"],   'beforeSave was fired and called in the context of the record'
      deepEqual @spies.beforeCommitSpy.lastCallArguments, [3, "Product"], 'beforeCommit was fired and called in the context of the record'

      deepEqual @spies.afterUpdateSpy.lastCallArguments, [4, "Product"], 'afterUpdate was fired and called in the context of the record'
      deepEqual @spies.afterSaveSpy.lastCallArguments, [5, "Product"],   'afterSave was fired and called in the context of the record'
      deepEqual @spies.afterCommitSpy.lastCallArguments, [6, "Product"], 'afterCommit was fired and called in the context of the record'

test 'destroying an existing record fires Destroy then Commit callbacks', ->
  @Product.find 10, (err, product) =>
    @spies.counter = 0
    product.destroy (err, prod) =>
      deepEqual @spies.beforeDestroySpy.lastCallArguments, [1, "Product"], 'beforeDestroy was fired first and called in the context of the record'
      deepEqual @spies.beforeCommitSpy.lastCallArguments, [2, "Product"], 'beforeCommit was fired and called in the context of the record'

      deepEqual @spies.afterDestroySpy.lastCallArguments, [3, "Product"], 'afterDestroy was fired second and called in the context of the record'
      deepEqual @spies.afterCommitSpy.lastCallArguments, [4, "Product"], 'afterCommit was fired and called in the context of the record'

QUnit.module "Batman.Model record lifecycle callbacks",
  setup: ->
    @beforeCreateSpy = beforeCreateSpy = createSpy()
    class @Product extends Batman.Model
      @encode 'name'
      @persist TestStorageAdapter

      @beforeCreate -> beforeCreateSpy()
      @beforeCreate -> beforeCreateSpy()

      @beforeDestroy -> return false

test 'each callback is fired', ->
  newProduct = new @Product(name: "Solar-powered Flashlight")
  newProduct.save (err, prod) =>
    equal @beforeCreateSpy.callCount, 2

test 'if a filter returns false, the operation is prevented', ->
  destroyCallbackSpy = createSpy
  @Product.find 10, (err, product) =>
    product.destroy (err, prod) =>
      destroyCallbackSpy()

  @Product.find 10, (err, product) =>
    ok product, "The product is still there"
    equal destroyCallbackSpy.callCount, undefined, "The callback isn't fired"
