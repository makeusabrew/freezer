db = require "./db"

getFirst = (cursor, callback) ->
  cursor.toArray (err, docs) ->
    return callback err, null if err

    callback null, if docs.length then docs[0] else null
Freezer =
  start: (callback) -> db.connect callback

  getSession: (url, callback) ->
    cursor = db.collection("session").find path: url
    cursor.sort(created: -1).limit(1)

    getFirst cursor, callback
  
  getCurrentSnapshot: (session, request, callback) ->
    #@TODO at the moment we always just serve the first snapshot...
    cursor = db.collection("snapshot").find sequenceId: session.sequenceId

    cursor.sort(_id: 1).limit(1)

    getFirst cursor, callback

  getSequenceByUrl: (url, callback) ->
    db.collection("sequence").findOne url: url, (err, object) ->
      callback err, object

  createSequenceForUrl: (url, callback) ->

    object =
      url: url
      created: new Date

    db.collection("sequence").insert object, (err, objects) ->
      return callback err, null if err

      callback null, objects[0]

  getLastSnapshot: (sequenceId, callback) ->
    cursor = db.collection("snapshot").find sequenceId: sequenceId

    cursor.sort _id: -1
    cursor.limit 1

    getFirst cursor, callback

  createSnapshot: (object, callback) ->
    db.collection("snapshot").insert object, (err, docs) ->
      return callback err, null if err

      callback null, docs[0]

  getSnapshotsForSequence: (sequenceId, callback) ->
    cursor = db.collection("snapshot").find sequenceId: sequenceId
    cursor.sort timestamp: 1
    cursor.toArray callback

  startSession: (options, callback) ->
    @getSequenceByUrl options.url, (err, sequence) =>
      return callback err, null if err

      return callback "No sequence for url #{options.url}", null if not sequence

      object =
        sequenceId: sequence._id
        path: options.path
        mode: options.mode
        created: new Date
        updated: new Date

      db.collection("session").insert object, (err, objects) ->
        return callback err, null if err

        session = objects[0]
        session.sequence = sequence

        callback null, session

module.exports = Freezer
