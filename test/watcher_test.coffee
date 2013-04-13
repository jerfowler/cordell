{mkdirSync, rmdirSync, writeFileSync,
 unlinkSync, existsSync, renameSync} = require 'fs'
{join} = require 'path'

{Watcher} = require '../src'

fixtures = join __dirname, 'fixtures'

fixture = (args...) ->
    args.unshift fixtures
    join args...

delay = (fn, ms=500) -> setTimeout fn, ms

describe 'Watcher', ->
    before ->
        # @spys =
        #     'add': sinon.spy()
        #     'add:file': sinon.spy()
        #     'add:dir': sinon.spy()
        #     'rem': sinon.spy()
        #     'rem:file': sinon.spy()
        #     'rem:dir': sinon.spy()
        #     'change': sinon.spy()
        #     'change:file': sinon.spy()
        #     'change:dir': sinon.spy()
        #     'watch': sinon.spy()
        #     'watch:file': sinon.spy()
        #     'watch:dir': sinon.spy()
        #     'unwatch': sinon.spy()
        #     'unwatch:file': sinon.spy()
        #     'unwatch:dir': sinon.spy()
        #     'error': sinon.spy()

        # @watcher.on 'rem', @spys['rem:file']
        # @watcher.on 'rem:file', @spys['rem:file']
        # @watcher.on 'rem:dir', @spys['rem:dir']
        # @watcher.on 'change', @spys['change:file']
        # @watcher.on 'change:file', @spys['change:file']
        # @watcher.on 'change:dir', @spys['change:dir']
        # @watcher.on 'watch', @spys['watch:file']
        # @watcher.on 'watch:file', @spys['watch:file']
        # @watcher.on 'watch:dir', @spys['watch:dir']
        # @watcher.on 'unwatch', @spys['unwatch:file']
        # @watcher.on 'unwatch:file', @spys['unwatch:file']
        # @watcher.on 'unwatch:dir', @spys['unwatch:dir']
        # @watcher.on 'error', @spys['error']

        # mkdirSync fixture 'a', 'b'
        # mkdirSync fixture 'a', 'b', 'c'
        # mkdirSync fixture 'a', 'd'
        # mkdirSync fixture 'a', 'e'
        # writeFileSync fixture 'a', 'b', '2.js'
        # writeFileSync fixture 'a', 'b', 'c', '3.js'
        # writeFileSync fixture 'a', 'd', '4.js'
        # writeFileSync fixture 'a', 'e', '5.js'
        # renameSync (fixture 'a', 'e'), (fixture 'a', 'd', 'e')
        # renameSync (fixture 'a', 'd'), (fixture 'a', 'b', 'c', 'd')
        # unlinkSync fixture 'a', 'b', 'c', 'd', 'e', '5.js'
        # unlinkSync fixture 'a', 'b', 'c', 'd', '4.js'
        # unlinkSync fixture 'a', 'b', 'c', '3.js'
        # unlinkSync fixture 'a', 'b', '2.js'
        # unlinkSync fixture 'a', '1.js'
        # rmdirSync fixture 'a', 'b', 'c', 'd', 'e'
        # rmdirSync fixture 'a', 'b', 'c', 'd'
        # rmdirSync fixture 'a', 'b', 'c'
        # rmdirSync fixture 'a', 'b'

    describe 'constructor options', ->
        it '`ignore` - option that skips filenames'
        it '`ignorePath` - option that skips directories'
        it '`match` - option that matches filenames'
        it '`matchPath` - option that matches directories'
        it '`debug` - option to turn on debug messages'
        it '`persistent` - option to pass to watchFile'
        it '`interval` - option to pass to watchFile'
        it '`module` - option to select the watch module'

    describe 'add', ->
        before ->
            @spys =
                'add': sinon.spy()
                'add:file': sinon.spy()
                'add:dir': sinon.spy()
                'error': sinon.spy()
            @watcher = new Watcher
            for own key, value of @spys
                @watcher.on key, value
            mkdirSync fixture 'a'
            writeFileSync fixture 'a', '1.js'
            @watcher.add fixture 'a'
            @watcher.add fixture 'a', '1.js'
            @watcher.add fixture 'x'

        after ->
            @watcher.close()
            for own key, value of @spys
                @watcher.removeListener key, value
                delete @spys[key]
            delete @watcher
            unlinkSync fixture 'a', '1.js'
            rmdirSync fixture 'a'

        beforeEach (done) ->
            delay done

        it 'Should emit `add` on new directories', ->
            @spys['add'].should.have.been.calledTwice

        it 'Should emit `add:dir` on new directories', ->
            @spys['add:dir'].should.have.been.calledOnce

        it 'Should emit `add` on new files', ->
            @spys['add'].should.have.been.calledTwice

        it 'Should emit `add:file` on new files', ->
            @spys['add:file'].should.have.been.calledOnce

        it 'Should emit `error` when there is an error', ->
            @spys['error'].should.have.been.calledOnce

        it 'Should ignore duplicate paths'

    describe 'rem', ->
        it 'Should emit `rem` on removed directories'
        it 'Should emit `rem:dir` on removed directories'
        it 'Should emit `rem` on removed files'
        it 'Should emit `rem:file` on removed files'
        it 'Should remove all subdirectories and files beneath the path'
        it 'Should not remove other files or dirs unless they\'re beneath path'

    describe 'watch', ->

        describe 'addDir', ->
            before (done) ->
                @spys =
                    'change': sinon.spy()
                    'change:dir': sinon.spy()
                    'watch': sinon.spy()
                    'watch:dir': sinon.spy()
                    'error': sinon.spy()
                @watcher = new Watcher(module:'watch')
                for own key, value of @spys
                    @watcher.on key, value
                mkdirSync fixture 'a'
                @watcher.addDir fixture 'a'
                writeFileSync (fixture 'a', '1.js'), 'change'
                delay ->
                    done()

            after ->
                @watcher.close()
                for own key, value of @spys
                    @watcher.removeListener key, value
                    delete @spys[key]
                delete @watcher
                unlinkSync fixture 'a', '1.js'
                rmdirSync fixture 'a'

            beforeEach (done) ->
                delay done

            it 'Should ignore duplicate paths'
            it 'Should emit `watch` when watching a directory', ->
                @spys['watch'].should.have.been.called

            it 'Should emit `watch:dir` when watching a directory', ->
                @spys['watch:dir'].should.have.been.calledOnce

            describe 'watch callback', ->
                it 'Should emit `error` when there is an error'
                it 'Should call `add` on all new files and directories'
                it 'Should call `rem` on all removed files and directories'
                it 'Should emit `change` when directories change'
                # , (done) ->
                #     writeFileSync (fixture 'a', '1.js'), 'change'
                #     delay =>
                #         @spys['change'].should.have.been.called
                #         done()
                it 'Should emit `change:dir` when directories change'
                # , (done) ->
                #     writeFileSync (fixture 'a', '1.js'), 'change:dir'
                #     delay =>
                #         @spys['change:dir'].should.have.been.calledOnce
                #         done()
                    # @spys['error'].should.have.been.calledOnce

        describe 'addFile', ->
            before (done) ->
                @spys =
                    'change': sinon.spy()
                    'change:file': sinon.spy()
                    'watch': sinon.spy()
                    'watch:file': sinon.spy()
                    'error': sinon.spy()

                @watcher = new Watcher
                for own key, value of @spys
                    @watcher.on key, value
                mkdirSync fixture 'a'
                writeFileSync fixture 'a', '1.js'
                @watcher.addFile fixture 'a', '1.js'
                delay ->
                    done()

            after ->
                @watcher.close()
                for own key, value of @spys
                    @watcher.removeListener key, value
                    delete @spys[key]
                delete @watcher
                unlinkSync fixture 'a', '1.js'
                rmdirSync fixture 'a'

            beforeEach (done) ->
                delay done

            it 'Should ignore duplicate paths'
            it 'Should emit `watch` when watching a file', ->
                @spys['watch'].should.have.been.called

            it 'Should emit `watch:file` when watching a file', ->
                @spys['watch:file'].should.have.been.calledOnce

            describe 'watch callback', ->

                it 'Should emit `change` when files change', (done) ->
                    writeFileSync (fixture 'a', '1.js'), 'change'
                    delay =>
                        @spys['change'].should.have.been.called
                        done()
                    
                it 'Should emit `change:file` when files change', (done) ->
                    writeFileSync (fixture 'a', '1.js'), 'change:file'
                    delay =>
                        @spys['change:file'].should.have.been.called
                        done()
                it 'Should not emit `add` and `add:file` events'

        describe 'remDir', ->
            it 'Should emit `unwatch` and `unwatch:dir` when watching a directory'

        describe 'remFile', ->
            it 'Should emit `unwatch` and `unwatch:file` when watching a file'


    describe 'watchFile', ->

        describe 'addDir', ->
            before (done) ->
                @spys =
                    'change': sinon.spy()
                    'change:dir': sinon.spy()
                    'watch': sinon.spy()
                    'watch:dir': sinon.spy()
                    'error': sinon.spy()
                @watcher = new Watcher
                for own key, value of @spys
                    @watcher.on key, value
                mkdirSync fixture 'a'
                @watcher.addDir fixture 'a'
                delay ->
                    done()

            after ->
                @watcher.close()
                for own key, value of @spys
                    @watcher.removeListener key, value
                    delete @spys[key]
                delete @watcher
                unlinkSync fixture 'a', '1.js'
                rmdirSync fixture 'a'

            beforeEach (done) ->
                delay done

            it 'Should ignore duplicate paths'
            it 'Should emit `watch` when watching a directory', ->
                @spys['watch'].should.have.been.called

            it 'Should emit `watch:dir` when watching a directory', ->
                @spys['watch:dir'].should.have.been.calledOnce

            describe 'watchFile callback', ->
                it 'Should emit `error` when there is an error'
                it 'Should call `add` on all new files and directories'
                it 'Should call `rem` on all removed files and directories'
                it 'Should emit `change` when directories change', (done) ->
                    writeFileSync (fixture 'a', '1.js'), 'change'
                    delay =>
                        @spys['change'].should.have.been.called
                        done()
                it 'Should emit `change:dir` when directories change', (done) ->
                    writeFileSync (fixture 'a', '1.js'), 'change:dir'
                    delay =>
                        @spys['change:dir'].should.have.been.calledOnce
                        done()
                    # @spys['error'].should.have.been.calledOnce

        describe 'addFile', ->
            before (done) ->
                @spys =
                    'change': sinon.spy()
                    'change:file': sinon.spy()
                    'watch': sinon.spy()
                    'watch:file': sinon.spy()
                    'error': sinon.spy()

                @watcher = new Watcher
                for own key, value of @spys
                    @watcher.on key, value
                mkdirSync fixture 'a'
                writeFileSync fixture 'a', '1.js'
                @watcher.addFile fixture 'a', '1.js'
                delay ->
                    done()

            after ->
                @watcher.close()
                for own key, value of @spys
                    @watcher.removeListener key, value
                    delete @spys[key]
                delete @watcher
                unlinkSync fixture 'a', '1.js'
                rmdirSync fixture 'a'

            beforeEach (done) ->
                delay done

            it 'Should ignore duplicate paths'
            it 'Should emit `watch` when watching a file', ->
                @spys['watch'].should.have.been.called

            it 'Should emit `watch:file` when watching a file', ->
                @spys['watch:file'].should.have.been.calledOnce

            describe 'watchFile callback', ->

                it 'Should emit `change` when files change', (done) ->
                    writeFileSync (fixture 'a', '1.js'), 'change'
                    delay =>
                        @spys['change'].should.have.been.called
                        done()
                    
                it 'Should emit `change:file` when files change', (done) ->
                    writeFileSync (fixture 'a', '1.js'), 'change:file'
                    delay =>
                        @spys['change:file'].should.have.been.called
                        done()
                it 'Should not emit `add` and `add:file` events'

        describe 'remDir', ->
            it 'Should emit `unwatch` and `unwatch:dir` when watching a directory'

        describe 'remFile', ->
            it 'Should emit `unwatch` and `unwatch:file` when watching a file'



    # it 'Expect fixture files to have been created', ->
    #     expect(existsSync fixture 'a', '1.js').to.be.true
    #     expect(existsSync fixture 'a', 'b', '2.js').to.be.true
    #     expect(existsSync fixture 'a', 'b', 'c', '3.js').to.be.true
    #     expect(existsSync fixture 'a', 'b', 'c', 'd', '4.js').to.be.true
    #     expect(existsSync fixture 'a', 'b', 'c', 'd', 'e', '5.js').to.be.true
        