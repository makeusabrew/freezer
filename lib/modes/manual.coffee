###
# manually serve snapshots; allows fine-grained control over exactly
# what snapshot to serve when
###
Base = require "./base"
Freezer = require "../freezer"

snapshotIndex = 0
snapshotCache = []

augmentSnapshot = (s, i) ->
  s._index = i+1
  s._date = new Date parseInt s.timestamp
  return s

class Manual extends Base
    getCurrentSnapshot: (request) -> return snapshotCache[snapshotIndex]

    getSnapshot: (index) -> return snapshotCache[index]

    getSnapshotIndex: -> return snapshotIndex

    loadRelative: (offset, callback) ->
      @loadAbsolute snapshotIndex+offset, callback

    loadAbsolute: (index, callback) ->
      snapshot = snapshotCache[index]
      callback "invalid snapshot index #{index}" if not snapshot

      Freezer.setSessionSnapshot @session._id, snapshot._id, (err) ->
        return callback err if err

        snapshotIndex = index
        callback()

    loadSnapshots: (callback) ->
      Freezer.getSnapshotsForSequence @session.sequenceId, (err, docs) ->
        throw err if err

        snapshotCache = (augmentSnapshot s,i for s,i in docs)

        callback snapshotCache

    getSnapshots: (callback) -> @loadSnapshots callback

    setSession: (session) -> @session = session

module.exports = Manual
