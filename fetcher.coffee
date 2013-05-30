# builtin/npm deps
request = require "request"
crypto  = require "crypto"

# local deps
db = require "./lib/db"

throw "Please supply a URL to fetch and a fetch interval in milliseconds" if process.argv.length isnt 4

[url, interval] = process.argv[2..]

# boot
db.connect ->
    console.log "DB connected"

    db.collection("sequence").findOne {url: url}, (err, object) ->
        throw err if err

        return fetchLastHash object if object

        createSequence (object) -> fetchLastHash object

createSequence = (callback) ->
    console.log "creating new sequence object for #{url}"

    object =
        url: url
        created: new Date

    db.collection("sequence").insert object, (err, objects) ->
        throw err if err

        object = objects[0]

        console.log "inserted new sequence #{object._id}"
        callback object

fetchLastHash = (sequence) ->
    console.log "fetching last snapshot hash for #{sequence.url}"

    cursor = db.collection("snapshot").find({sequenceId: sequence._id})

    cursor.sort _id: -1
    cursor.limit 1

    cursor.toArray (err, docs) ->
        throw err if err

        hash = if docs.length then docs[0].hash else null

        startSequence sequence, interval, hash

startSequence = (sequence, interval, hash) ->
    console.log "starting sequence #{sequence._id}, interval #{interval}, start hash: #{hash}"

    lastHash = hash

    do fetch = ->
        request sequence.url, (err, response, body) ->
            setTimeout fetch, interval

            return console.log "error fetching!" if err or response.statusCode isnt 200

            thisHash = getHash body

            return console.log "hashes match, no action" if thisHash is lastHash

            lastHash = thisHash

            data = parseJSON body

            return console.log "can't save JSON" if not data

            writeSnapshot sequence, body, data, thisHash

writeSnapshot = (sequence, raw, data, hash) ->
    object =
        sequenceId: sequence._id
        timestamp: Date.now()
        hash: hash
        data: data
        raw: raw

    db.collection("snapshot").insert object, (err, docs) ->
        throw err if err

        snapshot = docs[0]

        console.log "wrote snapshot #{snapshot._id}"

parseJSON = (data) ->
    try
        return JSON.parse data
    catch e
        return null

getHash = (data) ->
    hash = crypto.createHash "sha1"

    hash.update data

    return hash.digest "hex"
