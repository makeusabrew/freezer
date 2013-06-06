MongoClient = require("mongodb").MongoClient
ObjectID    = require("mongodb").ObjectID

#@TODO utilise proper config
env = process.env.NODE_ENV || "build"

#@TODO: un-hardcode
host   = "localhost"
port   = 27017
dbname = "freezer_#{env}"

db = null

exports =
  connect: (callback) ->
    callback() if db

    MongoClient.connect "mongodb://#{host}:#{port}/#{dbname}", (err, _db) ->
      throw err if err

      db = _db

      callback()

  collection: (name) -> db.collection name

  findById: (name, id, callback) -> @collection(name).findOne _id: id, callback

  toObjectId: (id) -> new ObjectID id

module.exports = exports
