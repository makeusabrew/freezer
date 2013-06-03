restify = require "restify"

#@TODO wrap all the callbacks here in named functions exposed by another
#object (e.g. Api.getSequences etc) - will be easier to tease apart the
#layers during testing

Freezer = require "../lib/freezer"

_id = (id) -> Freezer.toObjectId id

getResource = (resource) ->
  (req, res, next) ->
    Freezer["get#{resource}"] _id(req.params.id), (err, resource) ->
      return error res, err if err

      # @TODO why can't we use next() here?
      return notFound res if not resource

      res.send resource

loadRoutes = (server) ->
  server.get "/sequences/:id", getResource "Sequence"

  server.get "/sequences", (req, res) ->
    Freezer.getSequences req.params, (err, sequences) ->
      return error res, err if err
      res.send sequences

  #@TODO this only takes a URL as input...
  server.post "/sequences", (req, res) ->
    Freezer.createSequenceForUrl req.params.url, (err, sequence) ->
      return error res, err if err
      res.send sequence

  server.get "/sessions", (req, res) ->
    Freezer.getSessions req.params, (err, sessions) ->
      return error res, err if err
      res.send sessions

  server.post "/sessions", (req, res) ->
    options =
      url: req.params.url
      path: req.params.path
      mode: "manual" #@TODO from params...

    Freezer.createSession options, (err, session) ->
      return error res, err if err

      return res.send session

  server.put "/sessions/:id", (req, res) ->

    #@TODO: obviously this method is completely mismatched to the input...
    Freezer.setSessionSnapshot _id(req.params.id), _id(req.params.snapshotId), (err, session) ->
      return error res, err if err

      return res.send 200

  server.del "/sessions/:id", (req, res) ->
    Freezer.deleteSession _id(req.params.id), (err, deleted) ->
      return error res, err if err

      res.send deleted: deleted

  server.get "/snapshots", (req, res) ->
    # @TODO: this only serves snapshots for a given sequenceId
    Freezer.getSnapshotsForSequence _id(req.params.sequenceId), (err, snapshots) ->
      return error res, err if err

      return res.send snapshots

  # @see https://blog.apigee.com/detail/restful_api_design_what_about_counts
  server.get "/snapshots/count", (req, res) ->
    Freezer.countSnapshotsForSequence _id(req.params.sequenceId), (err, count) ->
      return error res, err if err

      return res.send count: count

  # snapshot collections get massive, so we *have* to expose a better query
  # @FIXME next doesn't seem to actually work, so for now this is hard coded
  # otherwise /snapshots/:id will never match
  server.get "/snapshots/last", (req, res, next) ->
    #return next() unless req.params.index is "last"

    Freezer.getLastSnapshot _id(req.params.sequenceId), (err, snapshot) ->
      return error res, err if err

      # @TODO is this really the right way of handling a non existent
      # single resource? If so we need to DRY it up a bit
      return notFound res if not snapshot

      return res.send snapshot

  server.get "/snapshots/:id", getResource "Snapshot"

  server.post "/snapshots", (req, res) ->
    #@TODO sanitize params
    req.params.sequenceId = _id(req.params.sequenceId)

    Freezer.createSnapshot req.params, (err, snapshot) ->
      return error res, err if err

      return res.send snapshot

error    = (res, err) -> res.send new restify.InternalError(err)
notFound = (res, msg="Resource not found") -> res.send new restify.ResourceNotFoundError msg

module.exports =
  start: (port) ->
    server = restify.createServer
      name: "freezer-api"
      version:" 0.0.1"

    server.pre restify.pre.userAgentConnection()
    server.pre restify.pre.pause()

    server.use restify.queryParser()
    server.use restify.bodyParser()

    server.use (req, res, next) ->
      # @TODO check debug etc...
      console.log "[API]", req.method, req.url
      next()

    loadRoutes server

    server.on "after", (req, res, route, err) ->
      console.log "[API] after", route

    server.listen port

    console.log "[API] server listening on port #{port}"
