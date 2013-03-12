# Cordell Walker - CI Ranger

One bad mofo of a walker, watcher, and CI utility

## What is this?

- An event based file/directory walker utility
- An event based file/directory watcher utility
- A CI enviroment utility linter/tester/watcher

### What about chokidar?

I like [chokidar](https://github.com/paulmillr/chokidar) and it was inspriation
for this project. However, I didn't like that chokidar didn't give me a listing of
what files are being watched, or a clean way to get a snapshot of the files that
already existed and those files that were added later.

### What does cordell do different?

- walking and watching functionality cleanly seperated
- more events that you can shake a stick at
- Crisp/clean coffeescript source
- A built-in CI environment that makes use of the watcher/walker combo

## How does it work?

### Install cordell
Cordell can be installed via the node.js package manager

        npm install cordell

Then just require the package like normal

```javascript
var cordell = require('cordell');

var walker = cordell.walk('file, dir, or array', {ignore: /^\./});
walker
    .on('file', function(path, stat){ 
        console.log('File', path, '[', stat.size, ']', 'was found...'); });
    .on('dir', function(path, stat, list){ 
        console.log('Directory', path, 'has', list.length, 'files...'); });
    .on('error', function(path, error){
        console.log('Error happened at', path, error); });
    .on('end', fucntion(files, stats){ 
        console.log('There were', files.length, 'total files found...'); });

walker.walk('file', 'dir', paths...)

// To reset the walker and emit a new `end` event
// walker.close()


var watcher = cordell.watch('file, dir, or array', {ignore: /^\./});
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
    .on('end', fucntion(files, stats){ 
        console.log('There were', files.length, 'initial files found...'); });

// To stop watching files
// watcher.close()

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