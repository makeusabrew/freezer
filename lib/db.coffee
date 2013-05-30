MongoClient = require("mongodb").MongoClient
ObjectID    = require("mongodb").ObjectID

#@TODO: un-hardcode
host   = "localhost"
port   = 27017
dbname = "freezer_test"

exports =
    db: {}
    connect: (callback) ->
        MongoClient.connect "mongodb://#{host}:#{port}/#{dbname}", (err, db) ->
            throw err if err

            exports.db = db
            callback()

    collection: (name) -> exports.db.collection name

    toObjectId: (id) -> new ObjectID id

module.exports = exports
