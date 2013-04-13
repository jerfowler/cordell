{EventEmitter} = require 'events'
Mocha = require 'mocha'

class Tester extends EventEmitter
    constructor: (config, logger) ->
        @_source = config.source ? /.*\.(coffee|js)$/
        @_config = config?.tester ? {}

        @_mocha = {}
        @_mocha.pattern = @_config.mocha?.pattern ? /^.*_test\.(coffee|js)$/
        @_mocha.options = @_config.mocha?.options ? reporter:'spec'
        @_mocha.tests = []

        @_debug = if config.debug?
            require('debug')("#{config.debug}:tester")
        else ->
        @_logger = logger ? console

    _mochaRun: (files) ->
        mocha = new Mocha(@_mocha.options)
        for file in files
            @_debug "Running #{file}..."
            @emit 'mocha:addFile', file
            mocha.addFile file
        mocha.run (failures) =>
            @emit 'mocha:failures', failures

    add: (paths...) ->
        for path in paths
            if @_mocha.pattern.test path
                @_mocha.tests.push path unless path in @_mocha.tests
        @

    rem: (paths...) ->
        for path in paths
            @_mocha.tests.splice i, 1 for i in @_mocha.tests when i is path
        @

    run: (path) ->
        if path? and path in @_mocha.tests
            @_mochaRun [path]
        else
            @_mochaRun @_mocha.tests
        @

    test: (paths...) ->
        files = paths.filter (file) => @_source.test file
        @add files...
        @run()        

    listen: (watcher, snapshot, delay=2000) ->
        return if @_config.enabled is off
        @_logger.info 'Running tests...'
        setTimeout =>
            @test snapshot...
            watcher.on 'add', (path) =>
                @add(path).run(path) if @_source.test path
            watcher.on 'rem', (path) =>
                @rem(path).run() if @_source.test path
            watcher.on 'change', (path) =>
                @run(path) if @_source.test path
        , delay

module.exports = exports = Tester