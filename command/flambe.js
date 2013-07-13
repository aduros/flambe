#!/usr/bin/env node
"use strict";
//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

var argparse = require("argparse");
var flambe = require("flambe");
var fs = require("fs");
var path = require("path");
var util = require("util");

var FlambeHelpFormatter = function (opts) {
    argparse.HelpFormatter.call(this, opts);
};
util.inherits(FlambeHelpFormatter, argparse.HelpFormatter);

// http://stackoverflow.com/questions/13423540/argparse-subparser-hide-metavar-in-command-listing
FlambeHelpFormatter.prototype._formatAction = function (action) {
    var parts = argparse.HelpFormatter.prototype._formatAction.call(this, action);
    if (action.nargs == argparse.Const.PARSER) {
        var lines = parts.split("\n");
        lines.shift();
        parts = lines.join("\n");
    }
    return parts;
};

var PLATFORMS = ["html", "flash", "ios", "android"];

var parser = new argparse.ArgumentParser({formatterClass: FlambeHelpFormatter});
parser.addArgument(["--config"], {defaultValue: "flambe.yaml"});

var commands = parser.addSubparsers({title: "Commands", metavar: "<command>"});

var cmd = commands.addParser("new", {help: "Create a new project scaffold"});
cmd.addArgument(["path"]);
cmd.setDefaults({action: function (args) {
    flambe.newProject(args.path);
    console.log("New Flambe project created in " + path.resolve(args.path));
}});

var cmd = commands.addParser("run", {help: "Build and run on given platform"});
cmd.addArgument(["platform"], {choices: PLATFORMS});
cmd.addArgument(["--debug"], {action: "storeTrue", help: "Build in debug mode"});
cmd.addArgument(["--fdb-host"], {help: "The address AIR apps should connect to for debugging"});
cmd.addArgument(["--no-fdb"], {action: "storeTrue", help: "Don't run fdb after starting AIR apps"})
cmd.setDefaults({action: function (args) {
    var config = flambe.loadConfig(args.config);
    flambe.run(config, args.platform, {debug: args.debug, fdbHost: args.fdb_host, noFdb: args.no_fdb})
    .catch(function (error) {
        if (error) console.error(error);
        process.exit(1);
    });
}});

var cmd = commands.addParser("build", {help: "Build multiple platforms"});
cmd.addArgument(["platforms"], {choices: PLATFORMS, nargs: "+"});
cmd.addArgument(["--debug"], {action: "storeTrue", help: "Build in debug mode"});
cmd.addArgument(["--fdb-host"], {help: "The address AIR apps should connect to for debugging"});
cmd.setDefaults({action: function (args) {
    var config = flambe.loadConfig(args.config);
    flambe.build(config, args.platforms, {debug: args.debug, fdbHost: args.fdb_host})
    .catch(function (error) {
        if (error) console.error(error);
        process.exit(1);
    });
}});

var cmd = commands.addParser("clean", {help: "Delete build and cache files"});
cmd.setDefaults({action: function () {
    flambe.loadConfig(args.config);
    flambe.clean();
}});

var cmd = commands.addParser("serve");
cmd.setDefaults({action: function (args) {
    flambe.loadConfig(args.config);
    var server = new flambe.Server();
    server.start();
}});

var args = parser.parseArgs();
args.action(args);
