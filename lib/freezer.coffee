db = require "./db"

Freezer =
  getSession: (request, callback) ->
    callback "not implemented", null
  
  getCurrentSnapshot: (session, callback) ->
    callback "not implemented", null

  getSequenceByUrl: (url, callback) ->
    db.collection("sequence").findOne url: url, (err, object) ->
      callback err, object

  createSequenceForUrl: (url, callback) ->

    object =
        url: url
        created: new Date

    db.collection("sequence").insert object, (err, objects) ->
      return callback err, null if err

      object = objects[0]

      callback object

  getLastSnapshot: (sequenceId, callback) ->
    cursor = db.collection("snapshot").find sequenceId: sequenceId

    cursor.sort _id: -1
    cursor.limit 1

    cursor.toArray (err, docs) ->
      return callback err, null if err

      callback null, if docs.length then docs[0] else null

  createSnapshot: (object, callback) ->
    db.collection("snapshot").insert object, (err, docs) ->
      return callback err, null if err

      callback null, docs[0]

module.exports = Freezer
