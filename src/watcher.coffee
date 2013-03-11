{EventEmitter} = require 'events'
{stat, readdir, watchFile, unwatchFile} = require 'fs'
{basename, join} = require 'path'

class Watcher extends EventEmitter
    _watching:
        files: {}
        dirs: {}
    constructor: (options={}) ->
        @_debug(options.debug) if options.debug?
        # Ignore nothing by default
        @_ignore = options.ignore ? /a^/
        @_ignorePath = options.ignorePath ? /a^/
        # Match everything by default
        @_match = options.match ? /.*/
        @_matchPath = options.matchPath ? /.*/

        @_options = {}
        @_options.persistent = options.persistent ? true
        @_options.interval = options.interval ? 100

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
        stat path, (err, stats) =>
            return @emit 'error', path, err if err
            return @_dir path, stats if stats.isDirectory()
            return @_file path, stats if stats.isFile()

    addDir: (path, list=[]) ->
        return if @_watching.dirs[path]
        @_watching.dirs[path] = (curr, prev) =>
            return if curr.mtime.getTime() <= prev.mtime.getTime()
            readdir path, (err, nl) =>
                return @emit 'error', path, err if err
                @rem join path, f for f in list when (nl.indexOf f) is -1
                @add join path, f for f in nl when (list.indexOf f) is -1
                list = nl
                @emit 'change', path, curr
                @emit 'change:dir', path, curr
        watchFile path, @_options, @_watching.dirs[path]
        @emit 'watch', path
        @emit 'watch:dir', path

    addFile: (path) ->
        return if @_watching.files[path]
        @_watching.files[path] = (curr, prev) =>
            return if curr.mtime.getTime() <= prev.mtime.getTime()
            @emit 'change', path, curr
            @emit 'change:file', path, curr
        watchFile path, @_options, @_watching.files[path]
        @emit 'watch', path
        @emit 'watch:file', path

    rem: (path) ->
        for own file, listener of @_watching.files
            if (file.indexOf path) is 0
                @remFile file
                @emit 'rem', path
                @emit 'rem:file', file
        for own dir, listener of @_watching.dirs
            if (dir.indexOf path) is 0
                @remDir dir
                @emit 'rem', path
                @emit 'rem:dir', dir

    remDir: (path) ->
        return unless @_watching.dirs[path]
        unwatchFile path, @_watching.dirs[path]
        delete @_watching.dirs[path]
        @emit 'unwatch', path
        @emit 'unwatch:dir', path

    remFile: (path) ->
        return unless @_watching.files[path]
        unwatchFile path, @_watching.files[path]
        delete @_watching.files[path]
        @emit 'unwatch', path
        @emit 'unwatch:file', path

    close: ->
        files = @_watching.files
        dirs = @_watching.dirs
        @_watching.files = {}
        @_watching.dirs = {}
        for own path, listener of files
            unwatchFile path, listener
            @emit 'unwatch', path
            @emit 'unwatch:file', path
        for own path, listener of dirs
            unwatchFile path, listener
            @emit 'unwatch', path
            @emit 'unwatch:dir', path

module.exports = exports = Watcher