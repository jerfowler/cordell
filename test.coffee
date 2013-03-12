global.chai = require 'chai'
global.expect = chai.expect
global.should = chai.should()
global.sinon = require 'sinon'
chai.use require 'sinon-chai'

cordell = require './src'

options =
    ignorePath: /fixtures/
    debug: 'cordell'
    persistent: true
    interval: 100
    linter:
        enabled: on
        coffeelint:
            pattern: /.*\.coffee$/
            options:
                indentation:
                    value: 4
                    level: "error"
    tester:
        enabled: on
        mocha:
            pattern: /^.*_test\.coffee$/
            options:
                reporter:'spec'

walker = cordell.ranger(['src', 'test'], options)
