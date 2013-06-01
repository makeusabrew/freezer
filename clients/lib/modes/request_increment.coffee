###
# this mode simply serves up sequential snapshots to clients, based on
# a crude combination of request IP & user agent
###
Base = require "./base"

snapshotIndex = {}

hashRequest = (request) -> request.connection.remoteAddress+":"+request.headers['user-agent']

class Manual extends Base
    getSnapshot: (request) ->
        hash = hashRequest request

        snapshotIndex[hash] = -1 if not snapshotIndex[hash]?

        snapshotIndex[hash] += 1

        return snapshotIndex[hash]

module.exports = Manual
