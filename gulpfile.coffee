# Configuration
build = './build'
dist = './dist'
source = './source'
test = './build/test'

# Preparations

gulp = require 'gulp'
version = (require './package.json').version

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
jeditor = require 'gulp-json-editor'
git = require 'gulp-git'

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
    .src ["#{source}/**/*.+(litcoffee|coffee)"]
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'compile-coffee', ["lint-coffee"], ->
  gulp
    .src ["#{source}/**/*.+(litcoffee|coffee)"]
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

gulp.task 'dist.git.branch', ->
  git.branch "dist-#{version}"
  return

gulp.task 'dist.git.checkout', ->
  return gulp
    .src ['.']
    .pipe git.checkout "dist-#{version}"

gulp.task 'dist.git.checkout.files', ->
  return gulp
    .src ['.']
    .pipe git.checkout "master", args:"-- .gitignore"

gulp.task 'dist.git.rm', ->
  return gulp
    .src [source, "./gulpfile.*", "coffeelint.*"]
    .pipe git.rm args:"-rf"

gulp.task 'dist.git.add', ->
  return gulp
    .src ["#{dist}/**/*"]
    .pipe git.add()

gulp.task 'dist.git.commit', ->
  return gulp
    .src ['.']
    .pipe git.commit "dist-#{version}"

gulp.task 'dist.package.json', ->
  return gulp
    .src ["package.json"]
    .pipe jeditor (json) ->
      delete json.devDependencies
      return json
    .pipe gulp.dest './'

gulp.task 'dist.git', (cb) ->
  runSequence 'dist.git.branch', 'dist.git.checkout', 'dist.git.checkout.files',
    'dist.git.rm', 'dist.git.add', 'dist.git.commit', cb

gulp.task 'dist.prettify', ["build"], (cb) ->
  gulp
    .src ["#{build}/**/*.js", "!#{build}/**/_*.js", "!#{test}/**/*"]
    .pipe prettify prettifyOptions
    .pipe gulp.dest dist

gulp.task 'dist.uglify', ["build"], ->
  gulp
    .src ["#{build}/**/*.js", "!#{build}/**/_*.js", "!#{test}/**/*"]
    .pipe uglify()
      .on 'error', (e) ->
        console.log '\x07', e.message
        return this.end()
    .pipe gulp.dest dist

gulp.task 'dist', (cb) ->
  runSequence 'dist.prettify', 'dist.git', cb

gulp.task 'mindist', (cb) ->
  runSequence 'dist.uglify', 'dist.git', cb

gulp.task 'default', (cb) ->
  runSequence 'build', 'test', cb
