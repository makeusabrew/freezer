template = require "swig"

class Controller
    constructor: ->
        #

    render: (tpl, data) ->
        tmpl = template.compileFile "#{tpl}.html"
        tmpl.render data

module.exports = Controller
