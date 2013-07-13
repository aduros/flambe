#!/usr/bin/env node
//
// Build and minify the embedder script

var flambe = require("flambe");

process.chdir(__dirname);
flambe.minify(["flambe.js", "swfobject.js"], "../flambe.js");
