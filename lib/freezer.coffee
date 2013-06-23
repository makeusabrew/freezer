###
# Think of this as the main API entry point into the system.
#
# As such it's quite large at the moment; feels like we at least need some
# neater mappers to avoid the constant db.collection and result manipulation
# stuff
###

# @TODO: DRY this file up
# @TODO: comment, or eradicate, its idiosyncracies
# @TODO: make its methods a bit more predictable and idiomatic; even if that
# means more composition

db = require "./db"

getFirst = (cursor, callback) ->
  cursor.toArray (err, docs) ->
    return callback err, null if err

    callback null, if docs.length then docs[0] else null

Freezer =
  start: (callback) -> db.connect callback

  getSession: (path, callback) ->
    cursor = db.collection("session").find path: path
    cursor.sort(created: -1).limit(1)

    getFirst cursor, callback

  getCurrentSnapshot: (session, request, callback) ->
    cursor = db.collection("snapshot").find _id: session.snapshotId

    cursor.sort(_id: 1).limit(1)

    getFirst cursor, callback

  getSequenceByUrl: (url, callback) ->
    db.collection("sequence").findOne url: url, (err, object) ->
      callback err, object

  createSequence: (params, callback) ->
    object =
      url: params.url
      name: params.name
      comments: params.comments
      created: new Date

    db.collection("sequence").insert object, (err, objects) ->
      return callback err, null if err

      callback null, objects[0]

  updateSequence: (id, params, callback) ->
    db.collection("sequence").findAndModify(
      {_id: id},
      {_id: 1},
      {$set: params}
      {new: true},
      callback
    )

  deleteSequence: (id, callback) ->
    db.collection("sequence").remove _id: id, callback

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

  countSnapshotsForSequence: (sequenceId, callback) ->
    db.collection("snapshot").count sequenceId: sequenceId, callback

  createSession: (options, callback) ->
    @getSequenceByUrl options.url, (err, sequence) =>
      return callback err, null if err

      # @TODO although it works with the outer API layer, throwing an error
      # for a null result here isn't consistent with what we do elsewhere
      # (which is just callback with a null object)
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

  getSequences: (params, callback) -> db.collection("sequence").find(params).toArray callback

  getSessions: (params, callback) -> db.collection("session").find(params).toArray callback

  getSnapshot: (id, callback) -> db.findById "snapshot", id, callback

  getSequence: (id, callback) -> db.findById "sequence", id, callback

  toObjectId: (id) -> db.toObjectId id

module.exports = Freezer
