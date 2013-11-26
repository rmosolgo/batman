{TestStorageAdapter} = window

QUnit.module "Batman.Model record lifecycle callbacks",
  setup: ->
    @spies = spies =
      counter: 0
      fireSpy: (spyName, otherArg) ->
        @counter += 1
        @["#{spyName}Spy"](@counter, otherArg)

    positions = ['before', 'after']
    actions = ['Create', 'Update', 'Destroy',]

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
      @beforeDestroy -> spies.fireSpy('beforeDestroy', @constructor.name)
      @afterDestroy -> spies.fireSpy('afterDestroy', @constructor.name)

test 'saving a new record fires Create callbacks', ->
  newProduct = new @Product(name: "Solar-powered Flashlight")
  @spies.counter = 0
  newProduct.save (err, prod) =>
    equal @spies.beforeCreateSpy.callCount, 1, 'beforeCreate was fired'
    deepEqual @spies.beforeCreateSpy.lastCallArguments, [1, "Product"], 'beforeCreate was fired first and called in the context of the record'
    equal @spies.afterCreateSpy.callCount, 1, 'afterCreate callback was fired'
    deepEqual @spies.afterCreateSpy.lastCallArguments, [2, "Product"], 'afterCreate was fired second and called in the context of the record'

test 'saving an existing record fires Update callbacks', ->
  @Product.find 10, (err, product) =>
    @spies.counter = 0
    product.save (err, prod) =>
      equal @spies.beforeUpdateSpy.callCount, 1, 'beforeUpdate was fired'
      deepEqual @spies.beforeUpdateSpy.lastCallArguments, [1, "Product"], 'beforeUpdate was fired first and called in the context of the record'
      equal @spies.afterUpdateSpy.callCount, 1, 'afterUpdate callback was fired'
      deepEqual @spies.afterUpdateSpy.lastCallArguments, [2, "Product"], 'afterUpdate was fired second and called in the context of the record'

test 'destroying an existing record fires Destroy callbacks', ->
  @Product.find 10, (err, product) =>
    @spies.counter = 0
    product.destroy (err, prod) =>
      equal @spies.beforeDestroySpy.callCount, 1, 'beforeDestroy was fired'
      deepEqual @spies.beforeDestroySpy.lastCallArguments, [1, "Product"], 'beforeDestroy was fired first and called in the context of the record'
      equal @spies.afterDestroySpy.callCount, 1, 'afterDestroy callback was fired'
      deepEqual @spies.afterDestroySpy.lastCallArguments, [2, "Product"], 'afterDestroy was fired second and called in the context of the record'
