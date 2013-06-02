restify = require "restify"

#@TODO trap API errors and convert them to something meaningful

#@TODO obviously need to take the API endpoint from config, not hard-coded!
client = restify.createJsonClient url: "http://localhost:9898"

getFirst = (result) -> if result[0]? then result[0] else null

module.exports =
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
