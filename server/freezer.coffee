http  = require "http"
Freezer = require "../lib/client"

Freezer.start ->
  server = http.createServer onRequest

  server.listen 9999
  console.log "Server ready..."

onRequest = (req, res) ->
  return res.end '' if req.url is "/favicon.ico"

  Freezer.getSession req.url, (err, session) ->
    return res.end "no active session for URL" if err or not session

    console.log "#{req.url} matches session for sequence #{session.sequenceId}"

    Freezer.getCurrentSnapshot session, req, (err, snapshot) ->
      res.setHeader "Access-Control-Allow-Origin", "*"
      res.setHeader "Content-Type", "application/json"

      res.end snapshot.raw

      console.log "served snapshot #{snapshot._id}: #{snapshot.timestamp}"
