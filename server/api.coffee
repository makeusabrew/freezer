restify = require "restify"

Client = require "../lib/client"

db = require  "../lib/db"

_id = (id) -> db.toObjectId id

loadRoutes = (server) ->
  server.get "/sequences", (req, res) ->
    Client.getSequences (err, sequences) ->
      res.send sequences

  server.post "/sequences", (req, res) ->
    Client.createSequenceForUrl req.params.url (err, sequences) ->
      res.send sequences

  server.post "/sessions", (req, res) ->
    options =
      url: req.params.url
      path: req.params.path
      mode: "manual"

    Client.startSession options, (err, session) ->
      return error res, err if err

      return res.send session

  server.put "/sessions/:id", (req, res) ->

    #@TODO: obviously this method is completely mismatched to the input...
    Client.setSessionSnapshot _id(req.params.id), _id(req.params.snapshotId), (err, session) ->
      return error res, err if err

      return res.send 200

  server.del "/sessions/:id", (req, res) ->
    Client.deleteSession _id(req.params.id), (err, deleted) ->
      return error res, err if err

      res.send deleted: deleted

  server.get "/snapshots", (req, res) ->
    Client.getSnapshotsForSequence _id(req.params.sequenceId), (err, snapshots) ->
      return error res, err if err

      return res.send snapshots

error = (res, err) -> res.send new restify.InternalError(err)

module.exports =
  start: (port) ->
    server = restify.createServer
      name: "freezer-api"
      version:" 0.0.1"

    server.pre restify.pre.userAgentConnection()

    server.use restify.queryParser()
    server.use restify.bodyParser()

    loadRoutes server

    server.listen port

    console.log "API server listening on port #{port}"
