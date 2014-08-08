var cwd = process.cwd();
var Git = require('git-wrapper');
var fs = require('fs');
var npm = require('npm');
var git = new Git;


var npm_install_args = [
  "gulp", "gulp-coffee", "gulp-cache", "gulp-coffeelint", "gulp-util",
  "gulp-mocha", "gulp-rimraf", "run-sequence", "coffee-script", "coffeelint",
  "coffeelint-stylish", "should", "gulp-exec", "gulp-rename", "gulp-uglify",
  "gulp-js-prettify", "gulp-git", "gulp-json-editor", "gulp-jade", "gulp-stylus",
  "gulp-watch", "cfx"
];

var git_master, git_dev;

git_master = function() {
  git.exec('checkout dev', function(err, msg) {
    if (err) throw(err);
    console.log(msg);

    git.exec('checkout master', function(err, msg) {
      if (err) throw(err);
      console.log(msg);

      git.exec('rm ./init.js', function(err, msg) {
        if (err) throw(err);
        console.log(msg);

        git.exec('rm README.md', function(err, msg) {
          if (!err && msg) console.log(msg);

          git.exec('rm package.json', function(err, msg) {
            if (!err && msg) console.log(msg);

            git.exec('update-ref -d refs/heads/master', function(err, msg) {
              git.exec('add .', function(err, msg) {
                if (err) throw(err);
                console.log(msg);

                git.exec('commit -m "Scaffold Initialized"', function(err, msg) {
                  if (err) throw(err);
                  console.log(msg);

                  git.exec('checkout --orphan clean', function(err, msg) {
                    if (err) throw(err);
                    console.log(msg);

                    git.exec('rm . -rf', function(err, msg) {
                      if (err) throw(err);
                      console.log(msg);

                      git.exec('update-ref -d refs/heads/clean', function(err, msg) {
                        if (err) throw(err);
                        console.log(msg);

                        fs.closeSync(fs.openSync('./README.md', 'w'));

                        git.exec('add ./README.md', function(err, msg) {
                          if (err) throw(err);
                          console.log(msg);

                          npm.commands.init(function(err) {
                            if (err) throw(err);

                            git.exec('add ./package.json', function(err, msg) {
                              if(err) throw(err);
                              console.log(msg);

                              git.exec('commit -m "Clean master"', function(err, msg) {
                                if (err) throw(err);
                                console.log(msg);

                                git.exec('checkout master', function(err, msg) {
                                  if (err) throw(err);
                                  console.log(msg);

                                  git.exec('rebase clean', function(err, msg) {
                                    if (err) throw(err);
                                    console.log(msg);

                                        git_dev();
                                  });
                                });
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  });
}

git_dev = function() {
  git.exec('checkout dev', function(err, msg) {
    if (err) throw(err);
    console.log(msg);

    git.exec('rm README.md', function(err, msg) {
      if (!err && msg) console.log(msg);

      git.exec('rm package.json', function(err, msg) {
        if(err) throw(err);
        console.log(msg);

        git.exec('update-ref -d refs/heads/dev', function(err, msg) {
          if (err) throw(err);
          console.log(msg);

          git.exec('add --all .', function(err, msg) {
            if (err) throw(err);
            console.log(msg);

            git.exec('commit -m "Scaffold Initialized"', function(err, msg) {
              if (err) throw(err);
              console.log(msg);

              git.exec('rebase clean', function(err, msg) {
                if (err) throw(err);
                console.log(msg);

                npm.commands.install(npm_install_args, function(err) {
                  if (err) throw(err);

                  git.exec('add ./package.json', function(err, msg) {
                    if (err) throw(err);
                    console.log(msg);

                    var pkg = require('./package.json')
                    fs.mkdirSync(cwd + '/' + pkg.name);
                    var cfx = require('cfx');
                    var proc = cfx.init({dir: cwd + '/' +pkg.name});
                    proc.stdout.on('data', function(data) { console.log(''+data); });
                    proc.on('close', function(err) {
                      if(err) throw(err)
                      fs.renameSync(cwd + '/' + pkg.name, cwd + '/source');
                      git.exec('add '+ cwd + '/source', function(err, msg){
                        if (err) throw(err)
                        console.log(msg);
                        git.exec('commit --amend --no-edit', function(err, msg) {
                          if (err) throw(err);
                          console.log(msg);
                          git.exec('remote rm origin', function(err, msg) {
                            if (!err && msg) console.log(msg);

                            git.exec('branch -D clean', function(err, msg) {
                              if (err) throw(err);
                              console.log(msg);

                              console.log("DONE!");
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  });
}

npm.load({"save-dev":true}, function(err) {
  if (err) throw(err);
  git_master();
});