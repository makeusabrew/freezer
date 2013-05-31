###
# manually serve snapshots; allows fine-grained control over exactly
# what snapshot to serve when
###
Base = require "./base"
db   = require "../db"

snapshotIndex = 0
snapshotCache = []

class Manual extends Base
    getCurrentSnapshot: (request) -> return snapshotCache[snapshotIndex]

    getSnapshot: (index) -> return snapshotCache[index]

    getSnapshotIndex: -> return snapshotIndex

    loadRelative: (offset) -> snapshotIndex += offset

    loadAbsolute: (index) -> snapshotIndex = index

    loadSnapshots: (callback) ->
      cursor = db.collection("snapshot").find sequenceId: @sequence._id
      cursor.sort timestamp: 1
      cursor.toArray (err, docs) ->
          throw err if err

          snapshotCache = docs

          # @TODO hugely crude and wasteful esp after a toArray
          snapshotCache.forEach (s, i) ->
            s._index = i+1
            s._date = new Date parseInt s.timestamp

          callback docs

    getSnapshots: (callback) -> @loadSnapshots callback

    setSequence: (sequence) -> @sequence = sequence

module.exports = Manual
