{TestStorageAdapter} = window

QUnit.module "Batman.Model record lifecycle callbacks",
  setup: ->
    @spies = spies =
      counter: 0
    positions = ['before', 'after']
    actions = ['Create', 'Update', 'Save', 'Initialize', 'Destroy',]

    for action in actions
      for position in positions
        @spies["#{position}#{action}Spy"] = createSpy()

    class @Product extends Batman.Model
      @encode 'name'
      @persist TestStorageAdapter

      @beforeCreate ->
        console.log("beforeCreateSpy")
        spies.counter += 1
        spies.beforeCreateSpy(spies.counter,@)

      @afterCreate ->
        console.log("afterCreateSpy")
        spies.counter += 1
        spies.afterCreateSpy(spies.counter,@constructor.name)

test 'the model is set up correctly', ->
  equal @Product._callbacks.creating.length, 1, 'one beforeCreate'
  equal @Product._callbacks.created.length, 1, 'one afterCreate'

test 'saving a new record fires Create and Save callbacks', ->
  newProduct = new @Product(name: "Solar-powered Flashlight")
  QUnit.stop()
  newProduct.save (err, prod) =>
    # QUnit.stop()
    equal @spies.beforeCreateSpy.called, true, 'beforeCreate was fired'
    equal @spies.beforeCreateSpy.lastCallArguments, [1, "Product"], 'beforeCreate was fired first and called in the context of the record'
    # equal @spies['beforeSaveSpy'].called, true, 'callback was fired'
    equal @spies.afterCreateSpy.called, true, 'afterCreate callback was fired'
    equal @spies.afterCreateSpy.lastCallArguments, [2, newProduct], 'afterCreate was fired first and called in the context of the record'

    # equal @spies['afterSaveSpy'].called, true, 'callback was fired'
