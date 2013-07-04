//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

var Q = require("q");
var fs = require("fs");
var path = require("path");
var spawn = require("child_process").spawn;
var wrench = require("wrench");
var xmldom = require("xmldom");

var DATA_DIR = __dirname + "/data";
var CACHE_DIR = ".flambe-cache";
var HAXE_COMPILER_PORT = "6000";

exports.loadConfig = function (output) {
    var yaml = require("js-yaml");
    return yaml.safeLoad(fs.readFileSync(output).toString());
};

exports.newProject = function (output) {
    wrench.copyDirSyncRecursive(DATA_DIR+"/scaffold", output);
};

exports.run = function (config, platform, opts) {
    opts = opts || {};
    var debug = opts.debug;

    var promise =
    exports.build(config, [platform], opts)
    .then(function () {
        var id = get(config, "id");
        switch (platform) {
        case "android":
            console.log();
            var apk = "build/main-android.apk";
            console.log("Installing: " + apk);
            adt(["-uninstallApp", "-platform", "android", "-appid", id],
                {verbose: false, output: false, check: false})
            .then(function () {
                return adt(["-installApp", "-platform", "android", "-package", apk],
                    {verbose: false});
            })
            .then(function () {
                return adt(["-launchApp", "-platform", "android", "-appid", id], {verbose: false});
            })
            .then(function () {
                if (debug) {
                    console.log();
                    // Clear the log, then start tailing it
                    return adb(["logcat", "-c"], {verbose: false}).then(function () {
                        return adb(["logcat", "-v", "raw", "-s", "air.%s:V" % id], {verbose: false});
                    });
                }
            })
            break;
        }
    });
    return promise;
};

exports.build = function (config, platforms, opts) {
    opts = opts || {};
    var debug = opts.debug;

    var commonFlags = [];

    // Flags common to all swf-based targets (flash, android, ios)
    swfFlags = ["--flash-strict", "-D", "native_trace",
        "-swf-header", "640:480:60:000000", "-lib", "hxsl"];
    if (debug) swfFlags.push("-D", "fdb", "-D", "advanced-telemetry");

    var buildHtml = function () {
        var htmlFlags = ["-D", "html"];
        var unminified = CACHE_DIR+"/main-html.unminified.js";
        var js = "build/web/targets/main-html.js";
        console.log("Building: " + js);
        if (debug) {
            return haxe(commonFlags.concat(htmlFlags).concat(["-js", js]));
        } else {
            // Minify release builds
            return haxe(commonFlags.concat(htmlFlags).concat(["-js", unminified]))
            .then(function () {
                return minify([unminified], js, {strict: true});
            });
        }
    };

    var buildFlash = function () {
        var swf = "build/web/targets/main-flash.swf";
        var flashFlags = swfFlags.concat(["-swf-version", "11", "-swf", swf]);
        console.log("Building: " + swf);
        return haxe(commonFlags.concat(flashFlags));
    };

    var buildAir = function (flags) {
        wrench.mkdirSyncRecursive(CACHE_DIR+"/air");
        wrench.copyDirSyncRecursive("assets", CACHE_DIR+"/air/assets", {
            excludeHiddenUnix: true,
            filter: /\.(ogg|wav|m4a)$/,
        });
        var airFlags = swfFlags.concat(["-lib", "air3", "-swf-version", "11.2", "-D", "flambe_air"]);
        return haxe(commonFlags.concat(airFlags).concat(flags))
    };

    var generateAirXml = function (swf, output) {
        var xml =
            "<application xmlns=\"http://ns.adobe.com/air/application/3.7\">\n" +
            "  <id>"+get(config, "id")+"</id>\n" +
            "  <versionNumber>"+get(config, "version")+"</versionNumber>\n" +
            "  <filename>"+get(config, "name")+"</filename>\n" +
            "  <initialWindow>\n" +
            "    <content>"+swf+"</content>\n" +
            "    <renderMode>direct</renderMode>\n" +
            "  </initialWindow>\n" +
            "</application>";
        var doc = new xmldom.DOMParser().parseFromString(xml);

        var icons = doc.createElement("icon");
        fs.readdirSync("icons").forEach(function (file) {
            // Only include properly named square icons
            var match = file.match(/^(\d+)x\1\.png$/);
            if (match) {
                var size = match[1];
                var image = doc.createElement("image"+size+"x"+size);
                image.appendChild(doc.createTextNode("icons/"+file));
                icons.appendChild(image);
            } else {
                console.warn("Invalid icon: icons/"+file);
            }
        });
        doc.documentElement.appendChild(icons);

        fs.writeFileSync(output, new xmldom.XMLSerializer().serializeToString(doc));
    };

    var buildAndroid = function () {
        var apk = "build/main-android.apk";
        console.log("Building: " + apk);

        var swf = "main-android.swf";
        var cert = CACHE_DIR+"/air/certificate-android.p12"
        var xml = CACHE_DIR+"/air/config-android.xml"

        var promise =
        buildAir(["-swf", CACHE_DIR+"/air/"+swf])
        .then(function () {
            // Generate a dummy certificate if it doesn't exist
            if (!fs.existsSync(cert)) {
                return adt(["-certificate", "-cn", "SelfSign", "-validityPeriod", "25", "2048-RSA",
                    cert, "password"]);
            }
        })
        .then(function () {
            generateAirXml(swf, xml);

            var apkType = debug ? "apk-debug" : "apk-captive-runtime";
            return adt(["-package", "-target", apkType, "-storetype", "pkcs12",
                "-keystore", cert, "-storepass", "password", apk, xml, "icons",
                "-C", CACHE_DIR+"/air", swf, "assets"]);
        })
        return promise;
    }

    wrench.mkdirSyncRecursive(CACHE_DIR);
    wrench.mkdirSyncRecursive("build/web/targets");
    copyDirContents("web", "build/web");
    copyFile(DATA_DIR+"/flambe.js", "build/web/flambe.js");
    wrench.copyDirSyncRecursive("assets", "build/web/assets", {forceDelete: true});

    var connectFlags = ["--connect", HAXE_COMPILER_PORT];
    var promise =
    haxe(connectFlags, {check: false, verbose: false, output: false})
    .then(function (code) {
        // Use a Haxe compilation server if available
        if (code == 0) {
            commonFlags = commonFlags.concat(connectFlags);
        }

        commonFlags.push("-main", get(config, "main"));
        commonFlags = commonFlags.concat(toArray(get(config, "haxe_flags", [])));
        commonFlags.push("-lib", "flambe", "-cp", "src");
        commonFlags.push("-dce", "full");
        if (debug) {
            commonFlags.push("-debug", "--no-opt", "--no-inline");
        } else {
            commonFlags.push("--no-traces");
        }
    })
    .then(function () {
        var builders = {
            html: buildHtml,
            flash: buildFlash,
            android: buildAndroid,
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
    var child = spawn(command, flags, {stdio: (opts.output === false) ? "ignore" : "inherit"});
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

var minify = function (inputs, output, opts) {
    opts = opts || {};
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
        flags.push("--js", input);
    });
    if (opts.strict) flags.push("--language_in", "ES5_STRICT");
    return exec("java", flags, {verbose: false});
};
exports.minify = minify;

var Server = function () {
};
exports.Server = Server;

Server.prototype.start = function () {
    var connect = require("connect");
    var url = require("url");

    // Fire up a Haxe compiler server, ignoring all output. It's fine if this command fails, the
    // build will fallback to not using a compiler server
    spawn("haxe", ["--wait", HAXE_COMPILER_PORT], {stdio: "ignore"});

    // Start a static HTTP server
    var host = "0.0.0.0";
    var port = 5000;
    var staticServer = connect()
        .use(function (req, res, next) {
            // Forever-cache assets
            if (url.parse(req.url, true).query.v) {
                expires = new Date(Date.now() + 1000*60*60*24*365*25);
                res.setHeader("Expires", expires.toUTCString());
                res.setHeader("Cache-Control", "max-age=315360000");
            }
            next();
        })
        .use(connect.logger("tiny"))
        .use(connect.compress())
        .use(connect.static("build/web"))
        .listen(port, host);
    console.log("Serving on %s:%s", host, port);
};

// TODO(bruno): Server.prototype.stop

/** Convert an "array-like" value to a real array. */
var toArray = function (o) {
    if (Array.isArray(o)) return o;
    if (a instanceof String) return o.split(" ");
    return [o];
};

/** Get a field from a config file. */
var get = function (config, name, defaultValue) {
    if (name in config) return config[name];
    if (typeof defaultValue != "undefined") return defaultValue;
    throw new Error("Missing required entry in config file: " + name);
};

/**
 * Copy all the files in a directory into another directory. Not a true merge, only one level deep.
 */
var copyDirContents = function (from, to) {
    fs.readdirSync(from).forEach(function (file) {
        var src = path.join(from, file);
        var dest = path.join(to, file);
        if (fs.statSync(src).isDirectory()) {
            wrench.copyDirSyncRecursive(src, dest, {forceDelete: true});
        } else {
            copyFile(src, dest);
        }
    });
};

var copyFile = function (from, to) {
    var content = fs.readFileSync(from);
    fs.writeFileSync(to, content);
};
