class Batman.RestStorage2 extends Batman.StorageAdapter
  fetch: (options, callback) ->
    new Batman.Request url: "/#{@model.storageKey}/#{options.id}.json", success: (json) =>
      record = Batman.currentApp.dataStore.populate(@model, json)
      callback?(record)

  fetchAll: (options, callback) ->
    new Batman.Request url: "/#{@model.storageKey}.json", success: (json) =>
      records = Batman.currentApp.dataStore.populate(@model, json)
      callback?(records)
