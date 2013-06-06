assert  = require "../../../test/lib/assert"
Helper  = require "../lib/helper"
server  = require("../../api").start 9876

Helper.host = "http://localhost:9876"

describe "REST API - Sequences Resource", ->
  before (done) ->
    Helper.start done

  describe "GET /sequences", ->
    before (done) ->
      Helper.get "/sequences", done

    it "should return a 200 OK", ->
      assert.equal 200, Helper.getStatus()

    it "should return the correct body", ->
      data = Helper.getJSON()

      assert.equal 1, data.length

      res = data[0]

      assert.equal "http://example.com/test", res.url

  describe "POST /sequences", ->
    before (done) ->
      params =
        url: "http://foo.com"
        name: "foo"

      Helper.post "/sequences", params, done

    # @TODO should this *actually* be a 201 created?
    it "should return a 200 OK", ->
      assert.equal 200, Helper.getStatus()

    it "should return the correct body", ->
      data = Helper.getJSON()

      assert.equal "http://foo.com", data.url
      assert.equal "foo", data.name

      assert.ok data._id
      assert.ok data.created
