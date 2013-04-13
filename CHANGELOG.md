# Cordell 0.1.5 (April 13, 2013)
* Fixed watcher module "watch" now watches directories correctly

# Cordell 0.1.4 (April 13, 2013)
* linter & tester are now EventEmitters
* Cordell::test - Catch mocha errors and use exit code
* watcher is now modular, can use watchFile (default) or watch
* FYI: watcher module "watch" doesn't watch directories? todo...


# Cordell 0.1.3 (March 14, 2013)
* Updated README
* added custom logger parameter to ranger
* linter & tester: fixed defaults when options are frozen
* walker: tweaked close functionality
* watcher: ignore duplicate paths on add
* more tests and pending tests... (TODO)


# Cordell 0.1.2 (March 13, 2013)
* More tests, even more pending...
* fixed run() chaining bug in tester
* fixed walker shared _files instance bug
* walker: Emit `closed` event when close() completes
* watcher: chainable methods
* watcher: better `rem` logic
* added test/config.coffee and cleaned up test.coffee


# Cordell 0.1.1 (March 12, 2013)
* Added more to README
* refactored linter & tester
* lint and test helper functions now exit without watching
* walker now only takes options in the constructor
* walker now can walk multiple times
* walker.close now resets the walker
* watcher change:dir event sends the directory listing


# Cordell 0.1.0 (March 11, 2013)
* Initial release.