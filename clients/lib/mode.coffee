module.exports =
    factory: (mode) ->
        object = require "#{__dirname}/modes/#{mode}"
        return new object
