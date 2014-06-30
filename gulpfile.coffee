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

# Tasks

gulp.task 'clean', ->
  gulp
    .src ["#{build}/*", "#{dist}/*", "#{test}/*"
            build, dist, test], read: false
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
    .pipe gulp.dest dist

gulp.task 'mindist', ["build"], ->
  gulp
    .src ["#{build}/**/*.js", "!#{build}/**/_*.js", "!#{test}/**/*"]
    .pipe uglify()
    .pipe gulp.dest dist

gulp.task 'default', (cb) ->
  runSequence 'build', 'test', cb
