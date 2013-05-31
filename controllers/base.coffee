template = require "swig"

class BaseController
    constructor: ->
        #

    render: (tpl, data) ->
        tmpl = template.compileFile "#{tpl}.html"
        tmpl.render data

module.exports = BaseController
