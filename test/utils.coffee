assert = require "assert"
Utils = require "../lib/utils"

describe "Utils", ->
    describe "formatJSON", ->
        result = null
        describe "with a valid JSON string", ->
            beforeEach ->
                result = Utils.formatJSON '{"foo":true,"bar":false}'

            it "returns a formatted string", ->
                expected = '{\n  "foo": true,\n  "bar": false\n}'
                assert.equal result, expected
