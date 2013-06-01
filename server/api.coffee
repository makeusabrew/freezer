restify = require "restify"

Client = require "../lib/client"

loadRoutes = (server) ->
  server.get "/sequences", (req, res, next) ->
    Client.getSequences (err, sequences) ->
      res.send sequences

  server.post "/sequences", (req, res, next) ->
    Client.createSequenceForUrl req.params.url (err, sequences) ->
      res.send sequences

module.exports =
  start: (port) ->
    server = restify.createServer
      name: "freezer-api"
      version:" 0.0.1"

    server.use restify.bodyParser()

    loadRoutes server

    server.listen port

    console.log "API server listening on port #{port}"
