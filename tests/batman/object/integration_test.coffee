integrationSuite = ->
  test 'runtime integration test', ->
    class Apple extends @klass
    a = new Apple
    a.set 'foo', 10

    class Banana extends @klass
      @accessor 'prop',
        get: (key) -> a.get('foo') + @get 'foo'

    b = new Banana
    b.set 'foo', 20
    equal b.get('foo'), 20
    b.observe 'prop', spy = createSpy()
    equal b.get('prop'), 30

    a.set('foo', 20)
    ok spy.called

    class Binding extends @klass
      @accessor {
        get: () -> b.get 'foo'
      }

    c = new Binding
    equal c.get('anything'), 20

    c.observe 'whatever', spy = createSpy()
    b.set 'foo', 1000
    ok spy.called

QUnit.module "Batman.Object integration",
  setup: ->
    @klass = Batman.Object

integrationSuite()

test "_batmanID accessor", ->
  object = Batman()
  ok object.get('_batmanID')?

QUnit.module "Batman.InternalObject integration",
  setup: ->
    @klass = Batman.InternalObject

integrationSuite()
