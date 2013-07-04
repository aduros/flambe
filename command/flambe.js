#!/usr/bin/env node

var argparse = require("argparse");
var flambe = require("flambe");
var fs = require("fs");
var path = require("path");

var PLATFORMS = ["html", "flash", "ios", "android"];

function loadConfig (args) {
    var yaml = require("js-yaml");
    return yaml.safeLoad(fs.readFileSync(args.config).toString());
};

var parser = new argparse.ArgumentParser();
parser.addArgument(["--config"], {defaultValue: "flambe.yaml"});

var commands = parser.addSubparsers({title: "Commands"});

var cmd = commands.addParser("new", {help: "Create a new project scaffold"});
cmd.addArgument(["path"]);
cmd.setDefaults({action: function (args) {
    flambe.scaffold(args.path);
    console.log("New Flambe project created in " + path.resolve(args.path));
}});

var cmd = commands.addParser("run", {help: "Build and run on given platform"});
cmd.addArgument(["platform"], {choices: PLATFORMS});
cmd.addArgument(["--debug"], {action: "storeTrue", help: "Build in debug mode"});
cmd.setDefaults({action: function (args) {
    flambe.run(loadConfig(args), args.platform, {debug: args.debug});
}});

var cmd = commands.addParser("build", {help: "Build multiple platforms"});
cmd.addArgument(["platforms"], {choices: PLATFORMS, nargs: "+"});
cmd.addArgument(["--debug"], {action: "storeTrue", help: "Build in debug mode"});
cmd.setDefaults({action: function (args) {
    flambe.build(loadConfig(args), args.platforms, {debug: args.debug})
    .then(function () {
        console.log("Build OK!");
    }, function (error) {
        console.log("Build error: " + error);
    });
}});

var cmd = commands.addParser("clean", {help: "Delete build and cache files"});
cmd.setDefaults({action: function () {
    flambe.clean();
}});

var cmd = commands.addParser("serve");
cmd.setDefaults({action: function (args) {
    console.log("TODO");
}});

var args = parser.parseArgs();
args.action(args);
