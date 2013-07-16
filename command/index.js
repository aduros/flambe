"use strict";
//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

var Q = require("q");
var fs = require("fs");
var os = require("os");
var path = require("path");
var spawn = require("child_process").spawn;
var wrench = require("wrench");
var xmldom = require("xmldom");

var DATA_DIR = __dirname + "/data";
var CACHE_DIR = "build/.cache";

var HAXE_COMPILER_PORT = 6000;
var HTTP_PORT = 5000;
var SOCKET_PORT = HTTP_PORT+1;

exports.PLATFORMS = ["html", "flash", "android"];

exports.VERSION = JSON.parse(fs.readFileSync(__dirname + "/package.json")).version;

exports.loadConfig = function (file) {
    var promise =
    Q.nfcall(fs.readFile, file)
    .catch(function (error) {
        throw new Error("Could not open '" + file + "'. Is this a valid project directory?");
    })
    .then(function (text) {
        var yaml = require("js-yaml");
        return yaml.safeLoad(text.toString());
    });
    return promise;
};

exports.newProject = function (output) {
    var promise =
    Q.nfcall(wrench.copyDirRecursive, DATA_DIR+"/scaffold", output, {})
    .then(function () {
        // Packaging it straight as .gitignore seems to create problems with NPM/Windows
        return Q.nfcall(fs.rename, output+"/_.gitignore", output+"/.gitignore");
    });
    return promise;
};

exports.run = function (config, platform, opts) {
    opts = opts || {};
    var debug = opts.debug;

    if (platform == null) {
        platform = get(config, "default_platform", "flash");
    }
    checkPlatforms([platform]);

    var run = function () {
        var id = get(config, "id");
        switch (platform) {
        case "android":
            var apk = "build/main-android.apk";
            console.log("Installing: " + apk);
            return adt(["-uninstallApp", "-platform", "android", "-appid", id],
                {output: false, check: false})
            .then(function () {
                return adt(["-installApp", "-platform", "android", "-package", apk]);
            })
            .then(function () {
                var p = adt(["-launchApp", "-platform", "android", "-appid", id]);
                if (debug && !opts.noFdb) {
                    console.log();
                    fdb(["run", "continue"]);
                }
                return p;
            })
            break;

        case "html": case "flash":
            var url = "http://localhost:" + HTTP_PORT + "/?flambe=" + platform;
            console.log("Launching: " + url);

            return exports.sendMessage("restart")
            .then(function (result) {
                var clients = (platform == "html") ? result.htmlClients : result.flashClients;
                if (clients < 1) {
                    // Open a new browser window if no connected clients, or this is a release build
                    var open = require("open");
                    open(url);
                    console.log("Opened in a new browser window.");
                } else {
                    console.log("Reloaded an existing browser window.");
                }
            })
            .catch(function (error) {
                return Q.reject("Development server not found. Run `flambe serve` in a another terminal and try again.");
            });
            break;
        }
    };

    return opts.noBuild ? run() : exports.build(config, [platform], opts).then(function () {
        console.log();
        return run();
    });
};

exports.build = function (config, platforms, opts) {
    opts = opts || {};
    var debug = opts.debug;

    if (platforms == null || platforms.length < 1) {
        platforms = [get(config, "default_platform", "flash")];
    }
    checkPlatforms(platforms);

    var commonFlags = [];

    // Flags common to all swf-based targets (flash, android, ios)
    var swfFlags = ["--flash-strict", "-swf-header", "640:480:60:000000"];
    if (debug) swfFlags.push("-D", "fdb", "-D", "advanced-telemetry");
    else swfFlags.push("-D", "native_trace");

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
        var airFlags = swfFlags.concat(["-swf-version", "11.7", "-D", "flambe_air"]);
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

            var androidFlags = ["-package"];
            if (debug) {
                var fdbHost = opts.fdbHost || getIP();
                androidFlags.push("-target", "apk-debug", "-connect", fdbHost);
            } else {
                androidFlags.push("-target", "apk-captive-runtime");
            }
            androidFlags.push("-storetype", "pkcs12", "-keystore", cert, "-storepass", "password",
                apk, xml, "icons", "-C", CACHE_DIR+"/air", swf, "assets");
            return adt(androidFlags);
        })
        return promise;
    }

    wrench.mkdirSyncRecursive(CACHE_DIR);
    wrench.mkdirSyncRecursive("build/web/targets");
    copyDirContents("web", "build/web");
    copyFile(DATA_DIR+"/flambe.js", "build/web/flambe.js");
    wrench.copyDirSyncRecursive("assets", "build/web/assets", {forceDelete: true});
    wrench.copyDirSyncRecursive("icons", "build/web/icons", {forceDelete: true});

    var connectFlags = ["--connect", HAXE_COMPILER_PORT];
    var promise =
    haxe(connectFlags, {check: false, verbose: false, output: false})
    .then(function (code) {
        // Hide the compilation server behind an environment variable for now until stable
        if ("FLAMBE_HAXE_SERVER" in process.env) {
            // Use a Haxe compilation server if available
            if (code == 0) {
                commonFlags = commonFlags.concat(connectFlags);
            }
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

exports.update = function (version, postInstall) {
    if (!postInstall) {
        // First update this command tool
        var npmFlags = (version != null)
            ? ["install", "-g", "flambe@"+version]
            : ["update", "-g", "flambe"];
        var promise =
        exec("npm", npmFlags)
        .then(function () {
            return exec("flambe", ["update", "--_postInstall"], {verbose: false});
        });
        return promise;

    } else {
        // Then update the Flambe haxelib
        return haxelib(["install", "flambe", exports.VERSION]);
    }
}

/** Sends a message to the Flambe Serve API. */
exports.sendMessage = function (method) {
    var http = require("http");
    var deferred = Q.defer();
    var options = {hostname: "localhost", port: HTTP_PORT, path: "/_api", method: "POST"};
    var req = http.request(options, function (res) {
        res.setEncoding("utf8");
        res.on("data", function (chunk) {
            var message = JSON.parse(chunk);
            if (message.error != null) {
                deferred.reject(message.error);
            } else {
                deferred.resolve(message.result);
            }
            // res.end();
        });
    });
    req.on("error", function (error) {
        deferred.reject(error);
    });
    req.end(JSON.stringify({method: method}));
    return deferred.promise;
};

var haxe = function (flags, opts) {
    return exec("haxe", flags, opts);
};
exports.haxe = haxe;

var haxelib = function (flags, opts) {
    return exec("haxelib", flags, opts);
};
exports.haxelib = haxelib;

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

    // Run everything through cmd.exe on Windows to be able to find .bat files
    if (process.platform == "win32") {
        flags.unshift("/c", command);
        command = "cmd";
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
            "/** Cooked with Flambe, https://getflambe.com */\n" +
            "%output%"];
    inputs.forEach(function (input) {
        flags.push("--js", input);
    });
    if (opts.strict) flags.push("--language_in", "ES5_STRICT");
    return exec("java", flags, {verbose: false});
};
exports.minify = minify;

var fdb = function (commands) {
    var child = spawn("fdb", [], {stdio: ["pipe", process.stdout, process.stderr]});
    commands.forEach(function (command) {
        child.stdin.write(command + "\n");
    });
    process.stdin.pipe(child.stdin);
};
exports.fdb = fdb;

var Server = function () {
};
exports.Server = Server;

Server.prototype.start = function () {
    var self = this;
    var connect = require("connect");
    var url = require("url");
    var websocket = require("websocket");

    // Hide the compilation server behind an environment variable for now until stable
    if ("FLAMBE_HAXE_SERVER" in process.env) {
        // Fire up a Haxe compiler server, ignoring all output. It's fine if this command fails, the
        // build will fallback to not using a compiler server
        spawn("haxe", ["--wait", HAXE_COMPILER_PORT], {stdio: "ignore"});
    }

    // Start a static HTTP server
    var host = "0.0.0.0";
    var staticServer = connect()
        .use(function (req, res, next) {
            var parsed = url.parse(req.url, true);
            if (parsed.pathname == "/_api") {
                // Handle API requests
                req.setEncoding("utf8");
                req.on("data", function (chunk) {
                    self._onAPIMessage(chunk)
                    .then(function (result) {
                        res.end(JSON.stringify({result: result}));
                    })
                    .catch(function (error) {
                        res.end(JSON.stringify({error: error}));
                    });
                });

            } else {
                if (parsed.query.v) {
                    // Forever-cache assets
                    var expires = new Date(Date.now() + 1000*60*60*24*365*25);
                    res.setHeader("Expires", expires.toUTCString());
                    res.setHeader("Cache-Control", "max-age=315360000");
                }
                next();
            }
        })
        .use(connect.logger("tiny"))
        .use(connect.compress())
        .use(connect.static("build/web"))
        .listen(HTTP_PORT, host);
    console.log("Serving on %s:%s", host, HTTP_PORT);

    this._wsServer = new websocket.server({
        httpServer: staticServer,
        autoAcceptConnections: true,
    });

    this._wsServer.on("connect", function (connection) {
        connection.on("message", function (message) {
            if (message.type == "utf8") {
                self._onMessage(message.utf8Data);
            }
        });
    });

    var net = require("net");
    this._connections = [];
    this._socketServer = net.createServer(function (connection) {
        self._connections.push(connection);
        connection.on("end", function () {
            self._connections.splice(self._connections.indexOf(connection, 1));
        });
        connection.on("data", function (data) {
            data = data.toString();
            if (data == "<policy-file-request/>\0") {
                // Handle Flash socket policy requests
                connection.end(
                    '<?xml version="1.0"?>' +
                    '<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">' +
                    '<cross-domain-policy>' +
                        '<allow-access-from domain="*" to-ports="'+SOCKET_PORT+'" />' +
                    '</cross-domain-policy>');
            } else {
                self._onMessage(data);
            }
        });
    });
    this._socketServer.listen(SOCKET_PORT, host);

    var watch = require("watch");
    var crypto = require("crypto");
    watch.createMonitor("assets", {interval: 200}, function (monitor) {
        monitor.on("changed", function (file) {
            console.log("Asset changed: " + file);
            var output = "build/web/"+file;
            if (fs.existsSync(output)) {
                var contents = fs.readFileSync(file);
                fs.writeFileSync(output, contents);
                self.broadcast("file_changed", {
                    name: path.relative("assets", file),
                    md5: crypto.createHash("md5").update(contents).digest("hex"),
                });
            }
        });
    });
};

/** Broadcast an event to all clients. */
Server.prototype.broadcast = function (type, params) {
    var event = {type: type};
    if (params) {
        for (var k in params) {
            event[k] = params[k];
        }
    }
    var message = JSON.stringify(event);
    this._wsServer.broadcast(message);
    this._connections.forEach(function (connection) {
        connection.write(message);
    });
};

/** Handle messages from connected game clients. */
Server.prototype._onMessage = function (message) {
    try {
        var event = JSON.parse(message);
        // switch (event.type) {
        // case "restart":
        //     this.broadcast("restart");
        // }
    } catch (error) {
        console.warn("Received badly formed message", error);
    }
};

/** Handle web API messages. */
Server.prototype._onAPIMessage = function (message) {
    try {
        message = JSON.parse(message);
    } catch (error) {
        return Q.reject("Badly formed JSON");
    }

    switch (message.method) {
    case "restart":
        this.broadcast("restart");
        return Q.resolve({
            htmlClients: this._wsServer.connections.length,
            flashClients: this._connections.length,
        });
    default:
        return Q.reject("Unknown method: " + message.method);
    }
};

// TODO(bruno): Server.prototype.stop

/** Convert an "array-like" value to a real array. */
var toArray = function (o) {
    if (Array.isArray(o)) return o;
    if (typeof o == "string") return o.split(" ");
    return [o];
};

/** Get a field from a config file. */
var get = function (config, name, defaultValue) {
    if (name in config) return config[name];
    if (typeof defaultValue != "undefined") return defaultValue;
    throw new Error("Missing required entry in config file: " + name);
};

var checkPlatforms = function (platforms) {
    for (var ii = 0; ii < platforms.length; ++ii) {
        var platform = platforms[ii];
        if (exports.PLATFORMS.indexOf(platform) < 0) {
            throw new Error("Invalid platform: '" + platform + "'. Choose from " + exports.PLATFORMS.join(", ") + ".");
        }
    }
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

var getIP = function () {
    var ip = null;
    var ifaces = os.networkInterfaces();
    for (var device in ifaces) {
        ifaces[device].forEach(function (iface) {
            if (!iface.internal && iface.family == "IPv4") {
                ip = iface.address;
            }
        });
    }
    return ip;
};
