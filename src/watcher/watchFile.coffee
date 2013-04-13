{readdir, watchFile, unwatchFile} = require 'fs'
{join} = require 'path'

class WatchFile

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
                @emit 'change:dir', path, curr, list[..]
        watchFile path, @_options, @_watching.dirs[path]
        @emit 'watch', path
        @emit 'watch:dir', path
        @

    addFile: (path) ->
        return if @_watching.files[path]
        @_watching.files[path] = (curr, prev) =>
            return if curr.mtime.getTime() <= prev.mtime.getTime()
            @emit 'change', path, curr
            @emit 'change:file', path, curr
        watchFile path, @_options, @_watching.files[path]
        @emit 'watch', path
        @emit 'watch:file', path
        @

    remDir: (path) ->
        return unless @_watching.dirs[path]
        unwatchFile path, @_watching.dirs[path]
        delete @_watching.dirs[path]
        @emit 'unwatch', path
        @emit 'unwatch:dir', path
        @

    remFile: (path) ->
        return unless @_watching.files[path]
        unwatchFile path, @_watching.dirs[path]
        delete @_watching.files[path]
        @emit 'unwatch', path
        @emit 'unwatch:file', path
        @

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
        @

module.exports = exports = WatchFile