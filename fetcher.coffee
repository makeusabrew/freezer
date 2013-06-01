# builtin/npm deps
request = require "request"
crypto  = require "crypto"

# local deps
db = require "./lib/db"
Freezer = require "./lib/freezer"

throw "Please supply a URL to fetch and a fetch interval in milliseconds" if process.argv.length isnt 4

[url, interval] = process.argv[2..]

db.connect ->
  Freezer.getSequenceByUrl url, (err, sequence) ->
    throw err if err

    return fetchLastHash sequence if sequence

    console.log "creating new sequence for #{url}"

    Freezer.createSequenceForUrl url, (err, sequence) ->
      console.log "inserted new sequence #{sequence._id}"
      fetchLastHash sequence

fetchLastHash = (sequence) ->
  Freezer.getLastSnapshot sequence._id, (err, snapshot) ->
    throw err if err

    hash = if snapshot then snapshot.hash else null

    startSequence sequence, interval, hash

startSequence = (sequence, interval, hash) ->
    console.log "starting sequence #{sequence._id}, URL #{sequence.url}, interval #{interval}, start hash #{hash}\n"

    lastHash = hash

    do fetch = ->
        request sequence.url, (err, response, body) ->
            setTimeout fetch, interval

            return console.log "error fetching!" if err or response.statusCode isnt 200

            thisHash = getHash body

            return process.stdout.write "." if thisHash is lastHash

            process.stdout.write "\n"

            data = parseJSON body

            return console.log "cannot save JSON" if not data

            # make sure we only save the hash once we're sure we can save
            lastHash = thisHash

            writeSnapshot sequence, body, data, thisHash

writeSnapshot = (sequence, raw, data, hash) ->
  object =
    sequenceId: sequence._id
    timestamp: Date.now()
    hash: hash
    data: data
    raw: raw

  Freezer.createSnapshot object, (err, snapshot) ->
      throw err if err

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
