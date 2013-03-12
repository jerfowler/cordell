{resolve} = require 'path'

module.exports.Walker = Walker = require './walker'
module.exports.Watcher = Watcher = require './watcher'
module.exports.Linter = Linter = require './linter'
module.exports.Tester = Tester = require './tester'

resetCache = (files) ->
    for path in files
        path = resolve path
        for key of require.cache
            if key is path
                delete require.cache[key]
                break

remItem: (items, item) ->
    items.splice i, 1 for i in items when i is item

module.exports.walk = (paths, options, watcher) ->
    new Walker(paths, options, watcher)

module.exports.watch = (paths, options={}, watcher) ->
    options.watch = on
    new Walker(paths, options, watcher)

module.exports.lint = (paths, options={}) ->
    linter = new Linter(options)
    walker = new Walker(paths, options)
    walker.on 'end', (files, stats) ->
        linter.lint files...

module.exports.test = (paths, options={}) ->
    tester = new Tester(options)
    walker = new Walker(paths, options)
    walker.on 'end', (files, stats) ->
        tester.test files...

module.exports.ranger = (paths, options={}) ->
    options.watch = on
    linter = new Linter(options)
    tester = new Tester(options)
    walker = new Walker(paths, options)
    walker.on 'end', (files, stats) ->
        console.log "Watching #{files.length} files..."
        walker.on 'add', (path) ->
            resetCache files
            files.push path
        walker.on 'rem', (path) ->
            resetCache files
            remItem files, path
        walker.on 'change', (path) ->
            resetCache files
        linter.listen walker, files, 1000
        tester.listen walker, files, 2000

module.exports.snapshot = (paths, options={}, callback) ->
    options.watch = off
    walker = new Walker(paths, options)
    walker.on 'end', callback