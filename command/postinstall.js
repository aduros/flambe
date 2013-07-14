#!/usr/bin/env node
"use strict";
//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

var flambe = require("flambe");

console.log("Running as " + process.getuid());
flambe.exec("haxelib", ["install", "flambe"])
.catch(function (error) {
    console.error("Error installing the Flambe haxelib. Is Haxe installed?");
    console.error(error);
    process.exit(1);
});
