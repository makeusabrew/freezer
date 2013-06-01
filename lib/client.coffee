###
# Think of this as the main API entry point into the system, e.g.
# effectively all of these methods will one day be mapped to a remote
# API endpoint (be it RESTful or whatever)
#
# As such it's quite large at the moment; feels like we at least need some
# neater mappers to avoid the constant db.collection and result manipulation
# stuff
###

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
    cursor = db.collection("snapshot").find _id: session.snapshotId

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
        snapshotId: null
        created: new Date
        updated: new Date

      db.collection("session").insert object, (err, objects) ->
        return callback err, null if err

        session = objects[0]
        session.sequence = sequence

        callback null, session

  setSessionSnapshot: (sessionId, snapshotId, callback) ->
    db.collection("session").findAndModify(
      {_id: sessionId},
      {_id: 1},
      {$set: snapshotId: snapshotId},
      {new: true},
      callback
    )

  deleteSession: (sessionId, callback) ->
    db.collection("session").remove _id: sessionId, callback

  getSequences: (callback) ->
    db.collection("sequence").find().toArray callback

module.exports = Freezer
