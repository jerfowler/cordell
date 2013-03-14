{EventEmitter} = require 'events'
{dirname, basename, join} = require 'path'
{stat, readdir} = require 'fs'
{isArray} = require 'util'

Watcher = require './watcher'

class Walker extends EventEmitter
    constructor: (paths, options={}, watcher) ->
        # Ignore nothing by default
        @_ignore = options.ignore ? /a^/
        @_ignorePath = options.ignorePath ? /a^/
        # Match everything by default
        @_match = options.match ? /.*/
        @_matchPath = options.matchPath ? /.*/
        @_options = options
        @_files = {}
        @_paths =  {}
        @_hasEnded = false
        @_debug options.debug if options.debug?
        @_watch watcher, options if watcher? or options.watch?
        if paths?
            paths = [paths] if not isArray paths
            @walk paths...

    _watch: (watcher, options) ->
        @_watcher = watcher ? new Watcher(options)
        @_watcher.on 'add:dir', (path, stats, list) =>
            @_stat join path, file for file in list
            @emit 'add:dir', path, stats, list[..]
            @emit 'dir', path, stats, list[..]
        @_watcher.on 'add:file', (path, stats) =>
            @_files[path] = stats
            @emit 'add', path, stats
            @emit 'file', path, stats
        @_watcher.on 'rem:dir', (path) =>
            @emit 'rem:dir', path
        @_watcher.on 'rem:file', (path) =>
            @_rem path
            @emit 'rem', path
            @emit 'unlink', path
        @_watcher.on 'change:dir', (path, stats, list) =>
            @emit 'change:dir', path, stats, list
        @_watcher.on 'change:file', (path, stats) =>
            @emit 'change', path, stats
        @_watcher.on 'error', (path, error) ->
            @emit 'error', path, error
        @on 'file', (path) ->
            @_watcher.addFile path
        @on 'dir', (path, stats, list) ->
            @_watcher.addDir path, list

    _debug: (name) ->
        debug = require('debug')("#{name}:walker")
        @on 'dir', (path) ->
            debug "Dir: #{path}"
        @on 'file', (path) ->
            debug "File: #{path}"
        @on 'other', (path) ->
            debug "Other #{path}"
        @on 'error', (path, error) ->
            debug "Error: #{path} - #{error.message}"
        @on 'end', (files) ->
            debug "End: #{files.length} files found"
        @on 'add', (path) ->
            debug "Add: #{path}"
        @on 'rem', (path) ->
            debug "Remove: #{path}"
        @on 'change', (path) ->
            debug "Change: #{path}"

    _rem: (path) ->
        delete @_files[path]

    _clone: (obj) ->
        clone = {}
        clone[key] = value for own key, value of obj
        clone

    _stat: (path) ->
        @_paths[path] = path
        stat path, (err, stats) =>
            return @_error path, err if err
            return @_dir path, stats if stats.isDirectory()
            return @_file path, stats if stats.isFile()
            @_other path, stats
            
    _dir: (path, stats) ->
        unless @_ignorePath.test path
            if @_matchPath.test path
                readdir path, (err, list) =>
                    return @_error path, err if err
                    @_stat join path, file for file in list
                    @emit 'dir', path, stats, list[..]
                    @_end(path)
            else @_end(path)
        else @_end(path)

    _file: (path, stats) ->
        unless @_ignore.test basename path
            if @_match.test basename path
                @_files[path] = stats
                @emit 'file', path, stats
        @_end(path)

    _other: (path, stats) ->
        @emit 'other', path, stats
        @_end(path)

    _error: (path, err) ->
        @emit 'error', path, err
        @_end(path)

    _end: (path) ->
        delete @_paths[path]
        return if @_hasEnded
        if Object.keys(@_paths).length is 0
            @emit 'end', Object.keys(@_files), @_clone(@_files)
            @_hasEnded = true

    _close: ->
        @_watcher?.close()
        @_files = {}
        @_paths = {}
        @_hasEnded = false
        @removeListener 'end', @_close
        @emit 'closed'
        @

    walk: (paths...) ->
        @_stat path for path in paths
        @

    close: ->
        return @_close() if @_hasEnded
        if Object.keys(@_paths).length isnt 0
            @on 'end', @_close
        @

module.exports = exports = Walker