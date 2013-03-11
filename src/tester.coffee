Mocha = require 'mocha'

class Tester
    _tests: []
    _source: null
    _config: null
    _pattern: null
    constructor: (config, logger) ->
        @_source = config.source ? /.*\.(coffee|js)$/
        @_config = config.mocha ? {}
        @_pattern = @_config.pattern ? /^.*_test\.(coffee|js)$/
        @_options = @_config.options ? reporter:'spec'
        @_debug = if config.debug?
            require('debug')("#{config.debug}:tester")
        else ->
        @_logger = logger ? console

    _rem: (item) ->
        @_tests.splice i, 1 for i in @_tests when i is item

    run: (files) ->
        mocha = new Mocha(@_options)
        for file in files
            @_debug "Running #{file}..."
            mocha.addFile file
        mocha.run()

    listen: (watcher, snapshot, delay=2000) ->
        return if @_config.enabled is off
        @_logger.info 'Running tests...'
        setTimeout =>
            @_tests = snapshot.filter (file) => @_pattern.test file
            @run @_tests
            watcher.on 'add', (path) =>
                if @_pattern.test path
                    @_tests.push path unless path in @_tests
                    @run [path]
                else if @_source.test path
                    @run @_tests

            watcher.on 'rem', (path) =>
                if @_pattern.test path
                    @_rem path

            watcher.on 'change', (path) =>
                if @_pattern.test path
                    @run [path]
                else if @_source.test path
                    @run @_tests
        , delay

module.exports = exports = Tester