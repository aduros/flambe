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

var parser = new argparse.ArgumentParser({formatterClass: FlambeHelpFormatter});
parser.addArgument(["--config"], {defaultValue: "flambe.yaml", help: "Alternate path to flambe.yaml."});

var commands = parser.addSubparsers({title: "Commands", metavar: "<command>"});

var cmd = commands.addParser("new", {help: "Create a new project scaffold.",
    description: "Creates a new project scaffold at the given path."});
cmd.addArgument(["path"]);
cmd.setDefaults({action: function (args) {
    flambe.newProject(args.path)
    .then(function () {
        console.log("New Flambe project created in " + path.resolve(args.path));
    })
    .catch(function (error) {
        console.error("Error: Could not create " + path.resolve(args.path));
        process.exit(1);
    });
}});

var addCommonArguments = function (parser) {
    parser.addArgument(["--debug"], {action: "storeTrue", help: "Build in debug mode."});
    parser.addArgument(["--fdb-host"], {help: "The address AIR apps should connect to for debugging."});
};

var cmd = commands.addParser("run", {help: "Build and run on given platform.",
    description: "Builds and runs the game on a single given platform."});
cmd.addArgument(["platform"], {choices: flambe.PLATFORMS});
addCommonArguments(cmd);
cmd.addArgument(["--no-fdb"], {action: "storeTrue", help: "Don't run fdb after starting AIR apps."})
cmd.setDefaults({action: function (args) {
    var config = flambe.loadConfig(args.config);
    flambe.run(config, args.platform, {debug: args.debug, fdbHost: args.fdb_host, noFdb: args.no_fdb})
    .catch(function (error) {
        if (error) console.error(error);
        process.exit(1);
    });
}});

var cmd = commands.addParser("build", {help: "Build multiple platforms.",
    description: "Builds the game for one or more platforms."});
cmd.addArgument(["platforms"], {choices: flambe.PLATFORMS, nargs: "+"});
addCommonArguments(cmd);
cmd.setDefaults({action: function (args) {
    var config = flambe.loadConfig(args.config);
    flambe.build(config, args.platforms, {debug: args.debug, fdbHost: args.fdb_host})
    .catch(function (error) {
        if (error) console.error(error);
        process.exit(1);
    });
}});

var cmd = commands.addParser("serve", {help: "Start a development server.",
    description: "Starts a development web server for testing browser games."});
cmd.setDefaults({action: function (args) {
    flambe.loadConfig(args.config);
    var server = new flambe.Server();
    server.start();
}});

var cmd = commands.addParser("clean", {help: "Delete build and cache files.",
    description: "Deletes the build and .flambe-cache directories."});
cmd.setDefaults({action: function () {
    flambe.loadConfig(args.config);
    flambe.clean();
}});

var cmd = commands.addParser("help");
cmd.addArgument(["command"], {nargs: "?"});
cmd.setDefaults({action: function () {
    if (args.command == null) {
        parser.printHelp();
    } else {
        if (args.command in commands.choices) {
            commands.choices[args.command].printHelp();
        } else {
            console.error("No help entry for " + args.command + ".");
            process.exit(1);
        }
    }
}});

var args = parser.parseArgs();
args.action(args);
