#!/usr/bin/env node
"use strict";
//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

var argparse = require("argparse");
var flambe = require("flambe");
var fs = require("fs");
var path = require("path");

var PLATFORMS = ["html", "flash", "ios", "android"];

var parser = new argparse.ArgumentParser();
parser.addArgument(["--config"], {defaultValue: "flambe.yaml"});

var commands = parser.addSubparsers({title: "Commands"});

var cmd = commands.addParser("new", {help: "Create a new project scaffold"});
cmd.addArgument(["path"]);
cmd.setDefaults({action: function (args) {
    flambe.newProject(args.path);
    console.log("New Flambe project created in " + path.resolve(args.path));
}});

var cmd = commands.addParser("run", {help: "Build and run on given platform"});
cmd.addArgument(["platform"], {choices: PLATFORMS});
cmd.addArgument(["--debug"], {action: "storeTrue", help: "Build in debug mode"});
cmd.setDefaults({action: function (args) {
    var config = flambe.loadConfig(args.config);
    flambe.run(config, args.platform, {debug: args.debug})
    .catch(function (error) {
        if (error) console.error(error);
        process.exit(1);
    });
}});

var cmd = commands.addParser("build", {help: "Build multiple platforms"});
cmd.addArgument(["platforms"], {choices: PLATFORMS, nargs: "+"});
cmd.addArgument(["--debug"], {action: "storeTrue", help: "Build in debug mode"});
cmd.setDefaults({action: function (args) {
    var config = flambe.loadConfig(args.config);
    flambe.build(config, args.platforms, {debug: args.debug})
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
