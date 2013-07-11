http  = require "http"

# app deps
Freezer = require "../lib/freezer"

onRequest = (req, res) ->
  return res.end '' if req.url is "/favicon.ico"

  Freezer.getSession req.url, (err, session) ->
    console.log "ERROR", err if err

    return res.end "no active session for URL" if err or not session

    Freezer.getCurrentSnapshot session, req, (err, snapshot) ->
      console.log "ERROR", err if err

      return res.end "could not fetch snapshot" if err or not snapshot

      res.setHeader "Access-Control-Allow-Origin", "*"
      res.setHeader "Content-Type", "application/json"

      res.end snapshot.raw

      date = new Date snapshot.timestamp
      console.log "[WEB] served #{snapshot._id}: #{date}"

Server =
  start: (port) ->
    server = http.createServer onRequest

    server.listen port
    console.log "Server listening on port #{port}"

module.exports = Server
