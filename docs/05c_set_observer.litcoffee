# /api/Data Structures/Batman.Set/Batman.SetObserver

`Batman.SetObserver` is used by a `Batman.SetProxy` to track the `SetProxy`'s `base` and the `items`. `SetObserver` is responsible for watching items enter and leave the `base` and observing those items for changes that are significant to the `SetProxy` (eg, changes to a sort key in a `SetSort`).


## ::constructor(@base : Batman.Set)

Creates, but doesn't start observing

## ::.observedItemKeys : Array

Will observe these props on children

## ::observerForItemAndKey(item, key) : Function

See SetIndex

## ::startObserving

Creates new observers for set and items

## ::stopObserving

Forgets all set and item observers

## ::startObservingItems

handles new items

## ::stopObservingItems

handles leaving all items
