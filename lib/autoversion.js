'use strict';

var readline = require('readline');
var semver   = require('semver');
var utils    = require('./utils');

var Autoversion = function() {
  this.events = {
    // format:
    // `eventName: [callback, ...]`
  };
};

Autoversion.prototype.utils = utils;

Autoversion.prototype.read = function() { return this; };
Autoversion.prototype.write = function(currentVersion, nextVersion) { return this; };

Autoversion.prototype.on = function(eventName, callback) {
  this.events[eventName] = this.events[eventName] || [];
  this.events[eventName].push(callback);
};
Autoversion.prototype.off = function(eventName, callback) {
  if (!callback) {
    delete this.events[eventName];
  } else {
    this.events[eventName].forEach(function(event) {
      if(event == callback) {
        delete this.events[eventName][event];
      }
    });
  }
};
Autoversion.prototype.trigger = function(eventName, args) {
  if (this.events[eventName]) {
    this.events[eventName].forEach(function(event) {
      event(args);
    });
  }
};


var autoversion = new Autoversion();

process.nextTick(function() {
  var argv = require('minimist')(process.argv.slice(2));
  var commands = argv._;

  var tasks = ['patch', 'minor', 'major'];
  var allTasks = tasks.slice();
  allTasks.unshift('version');

  if (commands.length > 1 || allTasks.indexOf(commands[0]) < 0) {
    console.log('Usage: autoversion ' + allTasks.join('|') + ' [-y, --yes]');
    return;
  }

  if (tasks.indexOf(commands[0]) < 0) {
    console.log( autoversion.read() );
  } else {
    var version = autoversion.read();
    var newVersion = semver.inc(version, commands[0]);

    var setVersion = function() {
      autoversion.write(version, newVersion);
      autoversion.trigger(commands[0], newVersion);
      autoversion.trigger('any', newVersion);
    };

    if (argv.y || argv.yes) {
      setVersion();
    } else {
      var rl = readline.createInterface(process.stdin, process.stdout);

      console.log('New version will be ' + newVersion);
      rl.question('Do you want to continue? [y/n] ', function(answer) {
        rl.close();

        if (['y', 'yes'].indexOf(answer.toLowerCase()) < 0) {
          console.log('Aborting!');
          process.exit(1);
        }

        setVersion();
      });

    }
  }

});

module.exports = autoversion
