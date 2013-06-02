restify = require "restify"

#@TODO trap API errors and convert them to something meaningful

#@TODO obviously need to take the API endpoint from config, not hard-coded!
client = restify.createJsonClient url: "http://localhost:9898"

getFirst = (result) -> if result[0]? then result[0] else null

module.exports =
  getSequence: (id, callback) ->
    client.get "/sequences/#{id}", (err, req, res, obj) ->
      callback null, obj

  getSequences: (callback) ->
    client.get "/sequences", (err, req, res, obj) ->
      callback null, obj

  getSequenceByUrl: (url, callback) ->
    client.get "/sequences?url=#{url}", (err, req, res, obj) ->

      callback null, getFirst obj

  createSequenceForUrl: (url, callback) ->
    client.post "/sequences", {url: url}, (err, req, res, obj) ->
      callback null, obj

  getLastSnapshot: (sequenceId, callback) ->
    client.get "/snapshots/last?sequenceId=#{sequenceId}", (err, req, res, obj) ->
      callback null, obj

  createSnapshot: (params, callback) ->
    client.post "/snapshots", params, (err, req, res, obj) ->
      callback null, obj

  getSnapshotsForSequence: (sequenceId, callback) ->
    client.get "/snapshots?sequenceId=#{sequenceId}", (err, req, res, obj) ->
      callback null, obj

  countSnapshotsForSequence: (sequenceId, callback) ->
    client.get "/snapshots/count?sequenceId=#{sequenceId}", (err, req, res, obj) ->
      callback null, obj.count

  getSessions: (callback) ->
    client.get "/sessions", (err, req, res, obj) ->
      callback null, obj

  createSession: (params, callback) ->
    client.post "/sessions", params, (err, req, res, obj) ->
      callback null, obj

  deleteSession: (sessionId, callback) ->
    client.del "/sessions/#{sessionId}", (err, req, res, obj) ->
      callback null, obj

  setSessionSnapshot: (sessionId, snapshotId, callback) ->
    client.put "/sessions/#{sessionId}", {snapshotId: snapshotId}, (err, req, res, obj) ->
      callback null
