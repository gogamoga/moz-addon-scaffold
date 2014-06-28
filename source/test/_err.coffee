# _err.coffee

should = require 'should'
util = require 'util'

do ->
  _err = (err) ->
    return (e = err) ->
      if util.isError e
        throw e
      else
        throw new Error e

  if module? and not module.parent
    module.exports = _err
  else
    describe '_err(err)', ->
      it 'should be a function', (done) ->
        _err.should.be.a.Function
        done()

      it 'should return a function', (done) ->
        _err().should.be.a.Function
        done()

    describe '_err(err)(e)', (done) ->
      it 'should throw an exception', (done) ->
        _err().should.throw()
        done()

      it 'should throw the "err" exception', (done) ->
        err = new Error
        (_err err).should.throwError err
        done()

      it 'should throw the "e" exception', (done) ->
        err = new Error
        e = new Error
        wrapper = () -> (_err err) e
        wrapper.should.throwError e
        done()

  return _err

