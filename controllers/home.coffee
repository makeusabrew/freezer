BaseController = require "./base"
#@TODO mappers, or maybe something like mongoose?
db = require "../lib/db"

class HomeController extends BaseController
    home: (req, res) ->
        db.collection("sequence").find().sort({_id: 1}).toArray (err, docs) =>
            res.send @render "index",
                page: "home"
                sequences: docs

module.exports = HomeController