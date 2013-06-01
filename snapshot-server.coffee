http  = require "http"
Freezer = {}

start = ->
  server = http.createServer onRequest

  server.listen 9999
  console.log "Snapshot server ready..."

onRequest = (req, res) ->
  Freezer.getSession req, (err, session) ->
    return res.end "no session" if err

    Freezer.getCurrentSnapshot session, (err, snapshot) ->
      res.setHeader "Access-Control-Allow-Origin", "*"
      res.setHeader "Content-Type", "application/json"

      res.end snapshot.raw

      console.log "served snapshot #{snapshot._index}) #{snapshot._date}"

start()
