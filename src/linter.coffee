coffeelint = require 'coffeelint'
jshint = require('jshint').JSHINT
{resolve} = require 'path'
fs = require 'fs'

read = (path) ->
    path = resolve path
    fs.readFileSync(path).toString()

class Linter
    constructor: (config, logger) ->
        @_source = config?.source ? /.*\.(coffee|js)$/
        @_config = config?.linter ? {}

        @_coffeelint = @_config.coffeelint ? {}
        @_coffeelint.options ?= {}
        @_coffeelint.pattern ?= /.*\.coffee$/

        @_jshint = @_config.jshint ? {}
        @_jshint.options ?= {}
        @_jshint.globals ?= {}
        @_jshint.pattern ?= /^(?!public(\/|\\)).*\.js$/

        @_debug = if config.debug?
            require('debug')("#{config.debug}:linter")
        else ->
        @_logger = logger ? console

    _csError: (err, file) ->
        @_logger.error "#{file}[#{err.lineNumber}] - #{err.message}
         #{if err.context? then ', '+err.context else ''}"

    _csLint: (file) ->
        try
            errors = coffeelint.lint read(file), @_coffeelint.options
            @_csError error, file for error in errors
        catch err
            @_logger.error "Coffeelint: (#{file}) - #{err.message}"

    _jsError: (err, file) ->
        @_logger.error "#{file}[#{err.line}] - #{err.reason}
         #{if err.evidence? then ', '+err.evidence else ''}"

    _jsLint: (file) ->
        success = jshint read(file), @_jshint.options, @_jshint.globals
        unless success
            @_jsError error, file for error in jshint.errors when error?

    lint: (file) ->
        @_debug "Linting #{file}..."
        if @_coffeelint.pattern.test file
            @_csLint file
        else if @_jshint.pattern.test file
            @_jsLint file

    listen: (watcher, snapshot, delay=1000) ->
        return if @_config.enabled is off
        @_logger.info 'Linting files...'
        setTimeout =>
            files = snapshot.filter (file) => @_source.test file
            @lint file for file in files
            watcher.on 'add', (path) =>
                @lint path if @_source.test path
            watcher.on 'change', (path) =>
                @lint path if @_source.test path
        , delay

module.exports = exports = Linter