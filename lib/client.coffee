restify = require "restify"

#@TODO trap API errors and convert them to something meaningful

#@TODO obviously need to take the API endpoint from config, not hard-coded!
client = restify.createJsonClient url: "http://localhost:9898"

getFirst = (result) -> if result[0]? then result[0] else null

module.exports =
  getSequence: (id, callback) ->
    client.get "/sequences/#{id}", (err, req, res, obj) ->
      callback err, obj

  getSequences: (callback) ->
    client.get "/sequences", (err, req, res, obj) ->
      callback err, obj

  getSequenceByUrl: (url, callback) ->
    client.get "/sequences?url=#{url}", (err, req, res, obj) ->

      callback err, getFirst obj

  createSequenceForUrl: (url, callback) ->
    client.post "/sequences", {url: url}, (err, req, res, obj) ->
      callback err, obj

  getLastSnapshot: (sequenceId, callback) ->
    client.get "/snapshots/last?sequenceId=#{sequenceId}", (err, req, res, obj) ->
      # @TODO DRY, neat and predictable way of handling
      return callback null, null if err and err.statusCode is 404

      callback err, obj

  createSnapshot: (params, callback) ->
    client.post "/snapshots", params, (err, req, res, obj) ->
      callback err, obj

  getSnapshotsForSequence: (sequenceId, callback) ->
    client.get "/snapshots?sequenceId=#{sequenceId}", (err, req, res, obj) ->
      callback err, obj

  countSnapshotsForSequence: (sequenceId, callback) ->
    client.get "/snapshots/count?sequenceId=#{sequenceId}", (err, req, res, obj) ->
      callback err, obj.count

  getSessions: (callback) ->
    client.get "/sessions", (err, req, res, obj) ->
      callback err, obj

  createSession: (params, callback) ->
    client.post "/sessions", params, (err, req, res, obj) ->
      callback err, obj

  deleteSession: (sessionId, callback) ->
    client.del "/sessions/#{sessionId}", (err, req, res, obj) ->
      callback err, obj

  setSessionSnapshot: (sessionId, snapshotId, callback) ->
    client.put "/sessions/#{sessionId}", {snapshotId: snapshotId}, (err, req, res, obj) ->
      callback err
