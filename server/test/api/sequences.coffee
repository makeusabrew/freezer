assert  = require "../../../test/lib/assert"
Helper  = require "../lib/helper"
server  = require("../../api").start 9876

Helper.host = "http://localhost:9876"

before (done) ->
  Helper.start done

describe "REST API - Sequences Resource", ->

  describe "GET /sequences", ->
    beforeEach (done) ->
      Helper.get "/sequences", done

    it "should return a 200 OK", ->
      assert.equal 200, Helper.getStatus()

    it "should return the correct body", ->
      data = Helper.getJSON()

      assert.equal 1, data.length

      res = data[0]

      assert.equal "http://example.com/test", res.url

  describe "POST /sequences", ->
    beforeEach (done) ->
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

  describe "GET /sequences/:id", ->
    describe "with an invalid resource ID", ->
      beforeEach (done) ->
        Helper.get "/sequences/123456789012", done

      it "should return a 404 Not Found", ->
        assert.equal 404, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal "Resource not found", data.message

    describe "with an invalid ID string", ->
      before (done) ->
        Helper.get "/sequences/1234", done

      it "should return a 404 Not Found", ->
        assert.equal 404, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal "Resource not found", data.message

    describe "with a valid resource ID", ->
      beforeEach (done) ->
        Helper.get "/sequences/4ed2b809d7446b9a0e000014", done

      it "should return a 200", ->
        assert.equal 200, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal "http://example.com/test", data.url
        assert.equal "A test sequence", data.name
        assert.equal "4ed2b809d7446b9a0e000014", data._id

  describe "PUT /sequences/:id", ->
    describe "with an invalid resource ID", ->
      beforeEach (done) ->
        Helper.put "/sequences/123456789012", {}, done

      it "should return a 404 Not Found", ->
        assert.equal 404, Helper.getStatus()

    describe "with a valid resource ID", ->
      beforeEach (done) ->
        params =
          url: "http://new.com"
          name: "New name"

        Helper.put "/sequences/4ed2b809d7446b9a0e000014", params, done

      it "should return a 200", ->
        assert.equal 200, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal "http://new.com", data.url
        assert.equal "New name", data.name

  describe "DELETE /sequences/:id", ->
    describe.skip "with an invalid resource ID", ->
      beforeEach (done) ->
        Helper.delete "/sequences/123456789012", done

      it "should return a 404 Not Found", ->
        assert.equal 404, Helper.getStatus()

    describe "with a valid resource ID", ->
      # @TODO set up this sequence *first*, then delete it and switch
      # to a beforeEach
      before (done) ->
        Helper.delete "/sequences/4ed2b809d7446b9a0e000014", done

      it "should return a 200", ->
        assert.equal 200, Helper.getStatus()

      it "should return the correct body", ->
        data = Helper.getJSON()

        assert.equal 1, data.deleted
