MongoClient = require("mongodb").MongoClient
ObjectID    = require("mongodb").ObjectID

#@TODO: un-hardcode
host   = "localhost"
port   = 27017
dbname = "freezer_test"

db = null

exports =
  connect: (callback) ->
    callback() if db

    MongoClient.connect "mongodb://#{host}:#{port}/#{dbname}", (err, _db) ->
      throw err if err

      db = _db

      callback()

  collection: (name) -> db.collection name

  findById: (name, id, callback) -> @collection(name).findOne _id: @toObjectId(id), callback

  toObjectId: (id) -> new ObjectID id

module.exports = exports
