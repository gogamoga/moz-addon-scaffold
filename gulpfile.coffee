# Configuration
build = './build'
dist = './dist'
src = './source'
test = './build/test'

# Preparations

gulp = require 'gulp'

runSequence = require 'run-sequence'
util = require 'gulp-util'
rimraf = require 'gulp-rimraf'
mocha = require 'gulp-mocha'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
exec = require 'gulp-exec'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
prettify = require 'gulp-js-prettify'

prettifyOptions =
  indent_size: 2
  indent_level: 0
  indent_char: ' '
  brace_style: 'collapse'
  break_chained_methods: false
  jslint_happy: true
  wrap_line_length: 70

# Tasks

gulp.task 'clean', ->
  gulp
    .src ["#{build}/*", "#{dist}/*", 
            build, dist], read: false
    .pipe rimraf force: true

gulp.task 'lint-coffee', ->
  gulp
    .src ["#{src}/**/*.+(litcoffee|coffee)"]
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'compile-coffee', ["lint-coffee"], ->
  gulp
    .src ["#{src}/**/*.+(litcoffee|coffee)"]
    .pipe coffee(bare: true).on 'error', util.log
    .pipe gulp.dest build

gulp.task 'compile', (cb) ->
  runSequence 'compile-coffee', cb

gulp.task 'test', ->
  gulp
    .src ["#{test}/**/*.js"], read: false
    .pipe mocha
      reporter: 'spec'
      globals:
        should: require 'should'

gulp.task 'build', (cb) ->
  runSequence 'clean', 'compile', cb

gulp.task 'dist', ["build"], ->
  gulp
    .src ["#{build}/**/*.js", "!#{build}/**/_*.js", "!#{test}/**/*"]
    .pipe prettify prettifyOptions
    .pipe gulp.dest dist

gulp.task 'mindist', ["build"], ->
  gulp
    .src ["#{build}/**/*.js", "!#{build}/**/_*.js", "!#{test}/**/*"]
    .pipe uglify()
      .on 'error', (e) ->
        console.log '\x07', e.message
        return this.end()
    .pipe gulp.dest dist

gulp.task 'default', (cb) ->
  runSequence 'build', 'test', cb
