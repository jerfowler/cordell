{stat, readdir, watch} = require 'fs'
{join} = require 'path'

class Watch

    addDir: (path, list=[]) ->
        return if @_watching.dirs[path]
        @_watching.dirs[path] = watch path, @_options, (evnt, name) =>
            stat path, (err, stats) =>
                return @emit 'error', path, err if err
                readdir path, (err, nl) =>
                    return @emit 'error', path, err if err
                    @rem join path, f for f in list when (nl.indexOf f) is -1
                    @add join path, f for f in nl when (list.indexOf f) is -1
                    list = nl
                    @emit 'change', path, stats
                    @emit 'change:dir', path, stats, list[..]
        @emit 'watch', path
        @emit 'watch:dir', path
        @

    addFile: (path) ->
        return if @_watching.files[path]
        @_watching.dirs[path] = watch path, @_options, (event, filename) =>
            if event is 'change'
                stat path, (err, stats) =>
                    return @emit 'error', path, err if err
                    @emit 'change', path, stats
                    @emit 'change:file', path, stats
            else if event is 'rename'
                @_watching.dirs[path].close()
                delete @_watching.dirs[path]
        @emit 'watch', path
        @emit 'watch:file', path
        @

    remDir: (path) ->
        return unless @_watching.dirs[path]
        @_watching.dirs[path].close()
        delete @_watching.dirs[path]
        @emit 'unwatch', path
        @emit 'unwatch:dir', path
        @

    remFile: (path) ->
        return unless @_watching.files[path]
        @_watching.dirs[path].close()
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
            listener.close()
            @emit 'unwatch', path
            @emit 'unwatch:file', path
        for own path, listener of dirs
            listener.close()
            @emit 'unwatch', path
            @emit 'unwatch:dir', path
        @

module.exports = exports = Watch