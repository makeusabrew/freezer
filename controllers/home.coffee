BaseController = require "./base"

class HomeController extends BaseController
    home: (req, res) ->
        res.send @render "index",
            page: "home"

module.exports = HomeController
