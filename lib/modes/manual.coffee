###
# manually serve snapshots; allows fine-grained control over exactly
# what snapshot to serve when
###
Base = require "./base"

snapshotIndex = 0

class Manual extends Base
    getSnapshot: (request) ->
        return snapshotIndex

module.exports = Manual
