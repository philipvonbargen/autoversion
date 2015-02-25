#!/usr/bin/env node

'use strict';

var fs          = require('fs');
var autoversion = require('../../../lib/autoversion');

var files = ['./tmp/package.json'];

autoversion.read = function() {
  var versions = [];
  files.forEach(function(file) {
    versions.push( require(file).version );
  });

  versions = autoversion.utils.arrayUnique(versions);

  if (versions.length > 1) {
    console.error('Version mismatch, aborting!');
    return;
  }

  return versions[0];
};

autoversion.write = function(currentVersion, nextVersion) {
  var filesLeft = files.length;
  files.forEach(function(file) {
    var content = require(file);
    content.version = nextVersion;

    fs.writeFile(file, JSON.stringify(content, null, '  '), function(err) {
      if (err) {
        console.error(err);
        return;
      }

      if (--filesLeft == 0) {
        console.log('All done!');
      }
    });
  });
};

autoversion.on('any', function(version) { console.log('Incremented ANY version. New version: ' + version) });
autoversion.on('patch', function(version) { console.log('Incremented PATCH version. New version: ' + version) });
autoversion.on('minor', function(version) { console.log('Incremented MINOR version. New version: ' + version) });
autoversion.on('major', function(version) { console.log('Incremented MAJOR version. New version: ' + version) });
