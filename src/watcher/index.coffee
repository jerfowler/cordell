{EventEmitter} = require 'events'
{stat, readdir, watchFile, unwatchFile, watch} = require 'fs'
{basename, join} = require 'path'

modules = 
    watch:     require './watch'
    watchFile: require './watchFile'

sep = if process.platform is 'win32' then '\\' else '/'

class Watcher extends EventEmitter
    constructor: (options={}, module) ->
        @_debug(options.debug) if options.debug?
        # Ignore nothing by default
        @_ignore = options.ignore ? /a^/
        @_ignorePath = options.ignorePath ? /a^/
        # Match everything by default
        @_match = options.match ? /.*/
        @_matchPath = options.matchPath ? /.*/
        @_watching = files: {}, dirs: {}
        @_options = {}
        @_options.persistent = options.persistent ? true
        @_options.interval = options.interval ? 100

        @_module = options.module ? 'watchFile'
        module ?= new modules[@_module]
        @[name] = method for name, method of module

    _debug: (name) ->
        debug = require('debug')("#{name}:watcher")
        @on 'add:file', (path) ->
            debug "Added File: #{path}"
        @on 'add:dir', (path) ->
            debug "Added Directory: #{path}"
        @on 'rem:file', (path) ->
            debug "Removed File: #{path}"
        @on 'rem:dir', (path) ->
            debug "Removed Directory: #{path}"
        @on 'change:file', (path) ->
            debug "Changed File: #{path}"
        @on 'change:dir', (path) ->
            debug "Changed Directory: #{path}"
        @on 'watch:file', (path) ->
            debug "Watching File: #{path}"
        @on 'watch:dir', (path) ->
            debug "Watching Directory: #{path}"
        @on 'unwatch:file', (path) ->
            debug "Unwatching File: #{path}"
        @on 'unwatch:dir', (path) ->
            debug "Unwatching Directory: #{path}"
        @on 'error', (path, error) ->
            debug "Error: #{path} - #{error.message}"

    _dir: (path, stats) ->
        unless @_ignorePath.test path
            if @_matchPath.test path
                readdir path, (err, list) =>
                    return @emit 'error', path, err if err
                    @emit 'add', path, stats
                    @emit 'add:dir', path, stats, list[..]
                    @addDir path, list

    _file: (path, stats) ->
        unless @_ignore.test basename path
            if @_match.test basename path
                @emit 'add', path, stats
                @emit 'add:file', path, stats
                @addFile path

    add: (path) ->
        return if @_watching.dirs[path]
        return if @_watching.files[path]
        stat path, (err, stats) =>
            return @emit 'error', path, err if err
            return @_dir path, stats if stats.isDirectory()
            return @_file path, stats if stats.isFile()
        @

    rem: (path) ->
        for own file, listener of @_watching.files
            if file is path
                @remFile file
                @emit 'rem', file
                @emit 'rem:file', file
                return @
            if (file.indexOf path+sep) is 0
                @remFile file
                @emit 'rem', file
                @emit 'rem:file', file

        for own dir, listener of @_watching.dirs
            if dir is path or (dir.indexOf path+sep) is 0
                @remDir dir
                @emit 'rem', dir
                @emit 'rem:dir', dir
        @

module.exports = exports = Watcher