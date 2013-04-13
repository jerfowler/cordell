{EventEmitter} = require 'events'
coffeelint = require 'coffeelint'
jshint = require('jshint').JSHINT
{resolve} = require 'path'
fs = require 'fs'

read = (path) ->
    path = resolve path
    fs.readFileSync(path).toString()

class Linter extends EventEmitter
    constructor: (config, logger) ->
        @_source = config?.source ? /.*\.(coffee|js)$/
        @_config = config?.linter ? {}

        @_coffeelint = {}
        @_coffeelint.options = @_config.coffeelint?.options ? {}
        @_coffeelint.pattern = @_config.coffeelint?.pattern ? /.*\.coffee$/

        @_jshint = {}
        @_jshint.options = @_config.jshint?.options = {}
        @_jshint.globals = @_config.jshint?.globals = {}
        @_jshint.pattern = @_config.jshint?.pattern = /^.*\.js$/

        @_debug = if config.debug?
            require('debug')("#{config.debug}:linter")
        else ->
        @_logger = logger ? console

    _csError: (file, err) ->
        @_logger.error "#{file}[#{err.lineNumber}] - #{err.message}
         #{if err.context? then ', '+err.context else ''}"
        @emit 'coffeelint:error', file, err

    _csLint: (file) ->
        try
            @emit 'coffeelint:file', file
            errors = coffeelint.lint read(file), @_coffeelint.options
            @_csError file, error for error in errors
        catch error
            @_csError file, error

    _jsError: (file, err) ->
        @_logger.error "#{file}[#{err.line}] - #{err.reason}
         #{if err.evidence? then ', '+err.evidence else ''}"
        @emit 'jshint:error', file, err

    _jsLint: (file) ->
        @emit 'jshint:file', file
        success = jshint read(file), @_jshint.options, @_jshint.globals
        unless success
            @_jsError error, file for error in jshint.errors when error?

    lint: (files...) ->
        for file in files when @_source.test file
            @_debug "Linting #{file}..."
            @emit 'file', file
            if @_coffeelint.pattern.test file
                @_csLint file
            else if @_jshint.pattern.test file
                @_jsLint file

    listen: (watcher, snapshot, delay=1000) ->
        return if @_config.enabled is off
        @_logger.info 'Linting files...'
        @emit 'listening'
        setTimeout =>
            @lint snapshot...
            watcher.on 'add', (path) =>
                @lint path if @_source.test path
            watcher.on 'change', (path) =>
                @lint path if @_source.test path
        , delay

module.exports = exports = Linter