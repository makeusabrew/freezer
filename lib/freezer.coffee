db = require "./db"

Freezer =
  getSession: (request, callback) ->
    callback "not implemented", null
  
  getCurrentSnapshot: (session, callback) ->
    callback "not implemented", null
