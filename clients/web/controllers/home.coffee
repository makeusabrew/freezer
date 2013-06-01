Controller = require "../../../lib/controller"
Freezer    = require "../../../lib/client"

class HomeController extends Controller
  home: (req, res) ->
    Freezer.getSequences (err, docs) =>
      res.send @render "index",
        page: "home"
        sequences: docs

module.exports = HomeController
