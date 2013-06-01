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

    loadRelative: (offset) -> snapshotIndex += offset

    loadAbsolute: (index) -> snapshotIndex = index

    loadSnapshots: (callback) ->
      Freezer.getSnapshotsForSequence @sequence._id, (err, docs) ->
        throw err if err

        snapshotCache = (augmentSnapshot s,i for s,i in docs)

        callback snapshotCache

    getSnapshots: (callback) -> @loadSnapshots callback

    setSequence: (sequence) -> @sequence = sequence

module.exports = Manual
