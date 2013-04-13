{mkdirSync, rmdirSync, writeFileSync, unlinkSync, existsSync} = require 'fs'
{join} = require 'path'

{Walker} = require '../src'

fixtures = join __dirname, 'fixtures'

fixture = (args...) ->
   args.unshift fixtures
   join args...

describe 'Walker', ->
    before ->
        mkdirSync fixture 'a'
        mkdirSync fixture 'a', 'b'
        mkdirSync fixture 'a', 'b', 'c'
        writeFileSync fixture 'a', '1.js'
        writeFileSync fixture 'a', 'b', '2.js'
        writeFileSync fixture 'a', 'b', 'c', '3.js'
    after ->
        unlinkSync fixture 'a', 'b', 'c', '3.js'
        unlinkSync fixture 'a', 'b', '2.js'
        unlinkSync fixture 'a', '1.js'
        rmdirSync fixture 'a', 'b', 'c'
        rmdirSync fixture 'a', 'b'
        rmdirSync fixture 'a'

    beforeEach ->
        @walker = new Walker

    # it 'Expect fixture files to have been created', ->
    #     expect(existsSync fixture 'a', '1.js').to.be.true
    #     expect(existsSync fixture 'a', 'b', '2.js').to.be.true
    #     expect(existsSync fixture 'a', 'b', 'c', '3.js').to.be.true

    describe 'constructor function', ->
        it 'takes an optional single path string'
        it 'takes an optional array of path strings'
        it 'takes an optional configuration object'
        it 'takes an optional watcher object and listens to its events'

        describe 'options', ->
            it '`ignore` - option that skips filenames'
            it '`ignorePath` - option that skips directories'
            it '`match` - option that matches filenames'
            it '`matchPath` - option that matches directories'
            it '`debug` - option to turn on debug messages'
            it '`watch` - option to create and listen to a watcher'

    describe 'method `walk`', ->
        it 'takes multiple path parameters'
        it 'can be called multiple times'
        it 'is chain-able, returns reference to `this`'

    describe 'method `close`', ->
        it 'resets walker if `end` event has already been emitted'
        it 'resets walker after `end` event has been emitted, if currently walking'
        it 'emits `closed` event when walker has been reset'
        it 'does nothing if not ended or walking'
        it 'is chain-able, returns reference to `this`'

    describe 'events emitted', ->

        it 'Should emit `file` event when a file is walked', (done) ->
            spy = sinon.spy()
            @walker.on 'file', spy
            @walker.on 'end', ->
                spy.should.have.been.calledThrice
                done()
            @walker.walk fixture 'a'

        it 'Should emit `dir` event when a directory is walked', (done) ->
            spy = sinon.spy()
            @walker.on 'dir', spy
            @walker.on 'end', ->
                spy.should.have.been.calledThrice
                done()
            @walker.walk fixture 'a'

        it 'Should emit `other` event when a special file is walked'

        it 'Should emit `error` event when the path doesn\'t exist', (done) ->
            spy = sinon.spy()
            @walker.on 'error', spy
            @walker.on 'end', ->
                spy.should.have.been.called
                done()
            @walker.walk fixture 'x'

        it 'Should emit `end` event when done walking', (done) ->
            spy = sinon.spy()
            @walker.on 'end', spy
            @walker.on 'end', (files, stats) ->
                spy.should.have.been.calledOnce
                done()
            @walker.walk fixture 'a'

        describe 'When the watcher is enabled', ->
            it 'Should emit `add` and `file` events when a new file is added'
            it 'Should emit `rem` and `unlink` events when a file is removed'
            it 'Should emit `change` event when a file has changed'
            it 'Should emit `add:dir` and `dir` events when a new directory is added'
            it 'Should emit `rem:dir` event when a directory is removed'
            it 'Should emit `change:dir` event when a directory has changed'

        describe '`file`, `add`, `change`, & `other` events', ->
            it 'Should pass a path'
            it 'Should pass a stats object'

        describe '`dir`, `add:dir`, & `change:dir` events', ->
            it 'Should pass a path'
            it 'Should pass a stats object'
            it 'Should pass a file list'

        describe '`rem`, `unlink` & `rem:dir` events', ->
            it 'Should pass a path'

        describe '`error` event', ->
            it 'Should pass a path'
            it 'Should pass an error object'

        describe '`end` event', ->
            it 'Should pass an array of filenames', (done) ->
                @walker.on 'end', (files, stats) ->
                    files.should.eql [
                        fixture 'a', '1.js'
                        fixture 'a', 'b', '2.js'
                        fixture 'a', 'b', 'c', '3.js'
                    ]
                    done()
                @walker.walk fixture 'a'

            it 'Should pass an object of stats objects keyed by filename', (done) ->
                @walker.on 'end', (files, stats) ->
                    expect(stats[fixture 'a', '1.js'].size).to.eql(9)
                    expect(stats[fixture 'a', 'b', '2.js'].size).to.eql(9)
                    expect(stats[fixture 'a', 'b', 'c', '3.js'].size).to.eql(9)
                    expect(Object.keys(stats).length).to.eql(3)
                    done()
                @walker.walk fixture 'a'

            it 'Should only be emitted once'