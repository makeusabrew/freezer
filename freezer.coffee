# builtin/npm deps
http = require "http"

# local deps
db = require "./lib/db"

throw "Please supply a URL to retrieve snapshots for" if process.argv.length isnt 3

currentSnapshot = 0
snapshotCache = []
url = require("url").parse process.argv[2]

# boot
db.connect ->

    db.collection("sequence").findOne {url: url.href}, (err, sequence) ->
        throw err if err

        throw "Cannot find sequence for URL #{url.href}" if not sequence

        start sequence

start = (sequence) ->
    server = http.createServer onRequest sequence

    server.listen 9999
    console.log "serving snapshots for sequence #{sequence._id}, URL: #{sequence.url}"

    getSnapshots sequence, (snapshots) ->
        snapshotCache = snapshots
        for snapshot,i in snapshots
            date = new Date snapshot.timestamp
            console.log "#{i+1}) #{date}"

onRequest = (sequence) ->
    (req, res) ->
        return res.end "invalid path" if req.url isnt url.path

        snapshot = snapshotCache[currentSnapshot]

        res.setHeader "Content-Type", "application/json"
        res.end snapshot.raw

        console.log "served snapshot #{currentSnapshot+1}"

getSnapshots = (sequence, callback) ->
    cursor = db.collection("snapshot").find sequenceId: sequence._id

    cursor.sort timestamp: 1

    cursor.toArray (err, docs) ->
        throw err if err
        callback docs
