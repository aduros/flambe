var Q = require("q");
var spawn = require("child_process").spawn;
var wrench = require("wrench");

// TODO(bruno): Find out the NPM-friendly way to do this
var DATA_DIR = "/home/bruno/dev/flambe/tools/cli/src/flambe/data";
var CACHE_DIR = ".flambe-cache";
var HAXE_COMPILER_PORT = "6000";

exports.scaffold = function (path) {
    wrench.copyDirSyncRecursive(DATA_DIR+"/scaffold", path);
};

exports.run = function (config, platform) {
    console.log(config);
};

exports.build = function (config, platforms, opts) {
    opts = opts || {};
    var debug = opts.debug;

    var commonFlags = [];

    var buildHtml = function () {
        console.log("HTML");
    };

    var buildFlash = function () {
        console.log("FLASH");
    };

    var connectFlags = ["--connect", HAXE_COMPILER_PORT];
    var promise =
    haxe(connectFlags, {check: false, verbose: false, output: false})
    .then(function (code) {
        // Use a Haxe compilation server if available
        if (code == 0) {
            commonFlags = commonFlags.concat(connectFlags);
        }

        commonFlags.push("-lib", "flambe", "-cp", "src", "-dce", "full");
        if (debug) {
            commonFlags.push("-debug", "--no-opt", "--no-inline");
        } else {
            commonFlags.push("--no-traces");
        }
        commonFlags = commonFlags.concat(toArray(get(config, "haxe_flags", [])));
    })
    .then(function () {
        var builders = {
            html: buildHtml,
            flash: buildFlash,
        };
        var promise = Q();
        platforms.forEach(function (platform, idx) {
            promise = promise.then(function () {
                if (idx != 0) console.log();
                return builders[platform]();
            });
        });
        return promise;
    });
    return promise;
};

exports.clean = function () {
    wrench.rmdirSyncRecursive("build", true);
    wrench.rmdirSyncRecursive(CACHE_DIR, true);
};

var haxe = function (flags, opts) {
    return exec("haxe", flags, opts);
};
exports.haxe = haxe;

var adt = function (flags, opts) {
    return exec("adt", flags, opts);
};
exports.adt = adt;

var adb = function (flags, opts) {
    return exec("adb", flags, opts);
};
exports.adb = adb;

var exec = function (command, flags, opts) {
    opts = opts || {};
    if (opts.verbose !== false) {
        console.log([command].concat(flags).join(" "));
    }

    var deferred = Q.defer();
    var child = spawn(command, flags);
    child.on("close", function (code) {
        if (code && opts.check !== false) {
            deferred.reject();
        }
        deferred.resolve(code);
    });
    child.on("error", function (error) {
        deferred.reject(error);
    });
    return deferred.promise;
};
exports.exec = exec;

var minify = function (inputs, output, strict) {
    var flags = ["-jar", DATA_DIR+"/closure.jar",
        "--warning_level", "QUIET",
        "--js_output_file", output,
        "--output_wrapper",
            "/**\n" +
            " * Cooked with Flambe\n" +
            " * https://github.com/aduros/flambe\n" +
            " */\n" +
            "%output%"];
    inputs.forEach(function (input) {
        command.push("--js", input);
    });
    if (strict) flags.push("--language_in", "ES5_STRICT");
    return exec("java", flags, {verbose: false});
};
exports.minify = minify;

var toArray = function (o) {
    if (Array.isArray(o)) return o;
    if (a instanceof String) return o.split(" ");
    return [o];
};

var get = function (config, name, defaultValue) {
    if (name in config) return config[name];
    if (typeof defaultValue != "undefined") return defaultValue;
    throw new Error("Missing required entry in config file: " + name);
};
