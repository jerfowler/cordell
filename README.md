# Cordell Walker - CI Ranger

One bad mother...

A walker, watcher, and CI utility that delivers a smooth roundhouse kick to your 
current development environment.

## What is this?

- An event based file / directory walker utility
- An event based file / directory watcher utility
- A CI environment utility linter / tester / watcher

### What about chokidar?

I like [chokidar](https://github.com/paulmillr/chokidar) and it was inspiration
for this project. However, I wanted a clean way to get a snapshot of the files that
already existed and those files that were added later. I wanted a utility that was a 
bit more verbose when describing what it was doing when it was doing it. I wanted a
utility that separated the recursive directory walking functionality from the file and
directory watching functionality. Finally, I wanted a utility that watched my files 
as I coded and immediately linted and tested them when there are changes.

I feel Cordell does all that and more.

### What does Cordell do different?

- walking and watching functionality cleanly separated
- more events that you can shake a stick at
- more configurable ignore and match options
- crisp / clean coffeescript source
- a built-in CI environment that makes use of the watcher / walker combo
    - [mocha](http://visionmedia.github.com/mocha/) tester
    - [coffeelint](http://www.coffeelint.org/)
    - [jshint](http://www.jshint.com/)

## How does it work?

### Install Cordell
Cordell can be installed via the node.js package manager

        npm install cordell

Then just require the package like normal

### Walking files & directories

```javascript
var cordell = require('cordell');

var walker = cordell.walk('file, dir, or array', {ignore: /^\./, match: /*.\.js$/});
walker
    .on('file', function(path, stat){ 
        console.log('File', path, '[', stat.size, ']', 'was found...'); });
    .on('dir', function(path, stat, list){ 
        console.log('Directory', path, 'has', list.length, 'files...'); });
    .on('error', function(path, error){
        console.log('Error happened at', path, error); });
    .on('end', function(files, stats){ 
        console.log('There were', files.length, 'total files found...'); });
        // To reset the walker and emit a new `end` event
        // walker.close();

// Add additional paths or wait till all your listeners are in place before walking
walker.walk('file', 'dir', paths...)
```

### Watching files & directories

```javascript
var watcher = cordell.watch('file, dir, or array', {ignore: /^\./, match: /*.\.js$/});
watcher
    .on('add', function(file, stat){
        console.log('File', path, 'has been added'); });
    .on('add:dir', function(file, stat, list){
        console.log('Directory', path, 'was added. With', list.length, 'files.'); });

    .on('rem', function(path){ // also emits optional 'unlink'
        console.log('File', path, 'has been removed'); });
    .on('rem:dir', function(path){
        console.log('Directoy', path, 'has been removed'); });

    .on('change', function(file, stat){ 
        console.log('File', path, 'has been changed'); });
    .on('change:dir', function(path, stat, list){
        console.log('Directoy', path, 'has changed. Now', list.length, 'files.');); });

    .on('error', function(path, error){
        console.log('Error happened at', path, error); });
    .on('end', function(files, stats){ 
        console.log('There were', files.length, 'initial files found...'); });

// To stop watching files
// watcher.close();
```

### Ranger CI functionality

```javascript
options = {
    ignorePath: /fixtures/,
    persistent: true,
    linter: {
        enabled: on,
        coffeelint: {
            pattern: /.*\.coffee$/,
            options: { indentation: { value: 4, level: "error" } }
        }
    },
    tester: {
        enabled: on,
        mocha: {
            pattern: /^.*_test\.coffee$/,
            options: { reporter:'spec' }
        }
    }
}

ranger = cordell.ranger(['src', 'test'], options);

```

## API

coming soon... (read the test files)