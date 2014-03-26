
QUnit.module 'Batman.TrackingHash',
  setup: ->
    obj =
      name: "Careless Whisper"
      artist: "George Michael"
    @trackingHash = new Batman.TrackingHash(obj)

test 'starts clean', ->
  ok @trackingHash.get('isClean')

test 'gets dirty', ->
  @trackingHash.set('artist', "Hall and Oates")
  ok @trackingHash.get('isDirty')

test 'doesnt get dirty from the same value', ->
  @trackingHash.set('artist', "George Michael")
  ok @trackingHash.get('isClean')

test 'setting back previous value makes it clean', ->
  @trackingHash.set('artist', "Hall and Oates")
  @trackingHash.set('artist', "George Michael")
  ok @trackingHash.get('isClean')

test 'setting a new key makes it dirty', ->
  @trackingHash.set("mood", "regretful")
  ok @trackingHash.get('isDirty')

test 'unsetting a key makes it dirty', ->
  @trackingHash.unset('artist')
  ok @trackingHash.get('isDirty')

test 'dirtiedKeys is a set of dirty keys', ->
  @trackingHash.set('artist', 'Michael McDonald')
  @trackingHash.set('featuredInstrument', 'saxophone')
  dirtiedKeys = @trackingHash.get('dirtiedKeys')
  ok dirtiedKeys instanceof Batman.Set, "it's a set"
  ok dirtiedKeys.has('artist'), "it has modified keys"
  ok dirtiedKeys.has('featuredInstrument'), "it has new keys"
  ok !dirtiedKeys.has('name'), "it doesnt have clean keys"

test 'dirtyKeys is a hash of dirty key-values', ->
  @trackingHash.set('artist', 'Michael McDonald')
  @trackingHash.set('featuredInstrument', 'saxophone')
  dirtyKeys = @trackingHash.get('dirtyKeys')
  equal dirtyKeys.get('artist'), "George Michael",  "it has modified keys"
  ok dirtyKeys.hasKey('featuredInstrument'), "it has new keys"
  ok !dirtyKeys.hasKey('name'), "it doesnt have clean keys"
