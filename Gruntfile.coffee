module.exports = (grunt) ->
    grunt.loadNpmTasks "grunt-simple-mocha"

    grunt.initConfig
        simplemocha:
            options:
                reporter: "spec"

            complete:
                src: ["**/test/*.coffee"]

    grunt.registerTask "test", ["simplemocha:complete"]
