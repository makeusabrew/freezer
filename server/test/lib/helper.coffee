qs      = require "querystring"
request = require "request"

# @TODO load db from config...
fixtures = require("pow-mongodb-fixtures").connect "freezer_#{process.env.NODE_ENV}"

Freezer = require "../../../lib/freezer"

Helper =
    host: ""
    response : {}
    
    get: (url, callback) ->
        @request "GET", url, null, callback

    post: (url, params, callback) ->
        @request "POST", url, params, callback

    put: (url, params, callback) ->
        @request "PUT", url, params, callback

    delete: (url, callback) ->
        @request "DELETE", url, null, callback

    request: (method, path, params, callback) ->
        host = @host
        url  = host + path

        options =
            uri: url
            method: method.toUpperCase()

        if params
            options.body = qs.stringify params
            options.headers =
                "Content-Type": "application/x-www-form-urlencoded"
            
        request options, (err, res) =>

            @response = res
            callback err

    getStatus: ->
        @response.statusCode

    getBody: ->
        @response.body

    getJSON: ->
        try
            data = JSON.parse @response.body
        catch e
            console.error "Could not parse JSON body: #{@response.body}"
            throw e

        return data

    getKey: (key) ->
        data = @getJSON()
        return data[key]

    start: (done) -> fixtures.clear -> Freezer.start done

module.exports = Helper
