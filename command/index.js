"use strict";
//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

var Q = require("q");
var fs = require("fs");
var ncp = require("ncp").ncp;
var os = require("os");
var path = require("path");
var spawn = require("child_process").spawn;
var wrench = require("wrench");
var xmldom = require("xmldom");

var DATA_DIR = __dirname + "/data/";
var BIN_DIR = __dirname + "/../bin/";
var CACHE_DIR = "build/.cache/";

var HAXE_COMPILER_PORT = 6000;
var HTTP_PORT = 7000;
var SOCKET_PORT = HTTP_PORT+1;

// The minimum SWF version for browser Flash. For AIR, we always use the latest
var SWF_VERSION = "11.2";

exports.PLATFORMS = ["html", "flash", "android", "ios", "firefox"];

exports.VERSION = JSON.parse(fs.readFileSync(__dirname + "/package.json")).version;

exports.loadConfig = function (file) {
    var promise =
    Q.nfcall(fs.readFile, file)
    .catch(function (error) {
        throw new Error("Could not open '" + file + "'. Is this a valid project directory?");
    })
    .then(function (text) {
        var yaml = require("js-yaml");
        // yaml barfs on tab indentation, replace with spaces. This can lead to problems with
        // mixed tabs/spaces on multiline values though...
        var converted = text.toString().replace(/^\t+/gm, function (tabs) {
            return tabs.replace(/\t/g, "    ");
        });
        return yaml.safeLoad(converted);
    });
    return promise;
};

exports.newProject = function (output) {
    var promise =
    Q.nfcall(wrench.copyDirRecursive, DATA_DIR+"scaffold", output, {})
    .then(function () {
        // Packaging it straight as .gitignore seems to create problems with NPM/Windows
        return Q.nfcall(fs.rename, output+"/_.gitignore", output+"/.gitignore");
    })
    .then(function () {
        // Can't include this empty directory in git, so create it manually
        return Q.nfcall(fs.mkdir, output+"/libs");
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

        case "android": case "ios":
            var app = (platform == "android") ? "build/main-android.apk" : "build/main-ios.ipa";
            console.log("Installing: " + app);
            return adt(["-uninstallApp", "-platform", platform, "-appid", id],
                {output: false, check: false})
            .then(function () {
                return adt(["-installApp", "-platform", platform, "-package", app]);
            })
            .then(function () {
                var p = adt(["-launchApp", "-platform", platform, "-appid", id]);
                if (debug && !opts.noFdb) {
                    console.log();
                    fdb(["run", "continue"]);
                }
                return p;
            })
            break;

        case "firefox":
            console.log("Open "+path.resolve("build/firefox")+" from about:app-manager in Firefox.");
            return Q.resolve();
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

    var assetPaths = getAllPaths(config, "assets");
    var libPaths = getAllPaths(config, "libs");
    var srcPaths = getAllPaths(config, "src");
    var webPaths = getAllPaths(config, "web");

    var _preparedWeb = false;
    var prepareWeb = function () {
        if (!_preparedWeb) {
            _preparedWeb = true;

            wrench.mkdirSyncRecursive("build/web/targets");
            copyFileSync(DATA_DIR+"flambe.js", "build/web/flambe.js");

            return copyDirs(webPaths, "build/web", {includeHidden: true})
            .then(function () {
                if (fs.existsSync("icons")) {
                    return copyDirs("icons", "build/web/icons");
                }
            });
        }
        return Q();
    };

    var generateAssetXml = function (relAssetDir, hxswfmlDoc) {
        forEachFileIn(relAssetDir, function (file) {
            var filePath = relAssetDir + "/" + file;
            if(fs.lstatSync(filePath).isDirectory()) {
                generateAssetXml(filePath, hxswfmlDoc);
            } else {
                var dataType = "";
                var extension = filePath.substring(filePath.lastIndexOf(".") + 1).toLowerCase();
                switch (extension) {
                    case "png":
                    case "jpg":
                    case "jpeg":
                    case "jxr":
                    case "gif":
                        dataType = "bitmap";
                        break;
                    case "mp3":
                        dataType = "sound";
                        break;
                    default:
                        dataType = "bytearray";
                        break;
                }

                var el = hxswfmlDoc.createElement(dataType);
                el.setAttribute("file", filePath);
                // create a valid AS3 class name from the asset url by replacing all non digits, non word characters, and leading non-letters with dollar signs
                var className = filePath.substring(filePath.indexOf("/") + 1, filePath.lastIndexOf(".")).replace(/[^\d|\w|\$]|^[^A-za-z]/g, '$');
                el.setAttribute("class", className);
                hxswfmlDoc.documentElement.appendChild(el);
            }
        });
    };

    var prepareEmbeddedAssetLibrary = function () {
        var hxswfmlDoc = new xmldom.DOMParser().parseFromString("<lib></lib>");
        assetPaths.forEach(function (assetPath) {
            generateAssetXml(assetPath, hxswfmlDoc);
        });
        hxswfmlDoc.documentElement.appendChild(hxswfmlDoc.createElement("frame"));

        var xmlPath = CACHE_DIR+"swf/hxswfml_asset_lib_def.xml";
        fs.writeFileSync(xmlPath, new xmldom.XMLSerializer().serializeToString(hxswfmlDoc));

        return hxswfml(["xml2lib", xmlPath, "libs/library.swf"]);
    };

    var prepareAssets = function (dest, platform) {
        var assetFlags = ["--macro", "flambe.platform.ManifestBuilder.use(\""+dest+"\")"];

        wrench.rmdirSyncRecursive(dest, true);
        if(fs.existsSync("libs/library.swf")) {
            fs.unlinkSync("libs/library.swf");
        }

        // TODO(bruno): Filter out certain formats based on the platform
        var promise = copyDirs(assetPaths, dest);
        if(platform == "flash" && get(config, "embed_assets")) {
            wrench.mkdirSyncRecursive(CACHE_DIR+"swf");
            assetFlags.push("-D", "embed_assets");

            promise = promise.then(function () {
                return prepareEmbeddedAssetLibrary()
            });
        }

        return promise.then(function () {
                return assetFlags;
        });
    };

    var swfFlags = function (air) {
        // Flags common to all swf-based targets (flash, android, ios)
        var flags = ["--flash-strict", "-swf-header", "640:480:60:000000"];
        if (debug) flags.push("-D", "fdb", "-D", "advanced-telemetry");
        else flags.push("-D", "native_trace");

        // Include any swc/swf libs in the libs directories
        libPaths.forEach(function (libPath) {
            forEachFileIn(libPath, function (file) {
                if (file.match(/.*\.(swc|swf)$/)) {
                    flags.push("-swf-lib", libPath+"/"+file);
                } else if (air && file.match(/.*\.ane$/)) {
                    // flags.push("-swf-lib-extern", libPath+"/"+file);
                    // The current version of Haxe can't deal with .ane -swf-libs, so rename it to a
                    // swc first
                    var swc = CACHE_DIR+"air/"+file+".swc";
                    wrench.mkdirSyncRecursive(CACHE_DIR+"air");
                    copyFileSync(libPath+"/"+file, swc);
                    flags.push("-swf-lib-extern", swc);
                }
            });
        });
        return flags;
    };

    var buildJS = function (opts) {
        var target = opts.target;
        var outputDir = opts.outputDir;
        var assetFlags = opts.assetFlags;

        var assetDir = outputDir + "/assets";
        var unminified = CACHE_DIR + target + ".unminified.js";
        var js = outputDir + "/targets/main-" + target + ".js";

        wrench.mkdirSyncRecursive(outputDir);

        var jsFlags = ["-D", target, "-D", "js-es5", "-D", "js-flatten"];
        var flags = commonFlags.concat(jsFlags).concat(assetFlags);
        if (debug) {
            return haxe(flags.concat(["-D", "source-map-content", "-js", js]));
        } else {
            // Minify release builds
            return haxe(flags.concat(["-js", unminified]))
            .then(function () {
                return minify([unminified], js, {strict: true});
            })
            .then(function () {
                // Delete the source map file produced by debug builds
                return Q.nfcall(fs.unlink, js+".map")
                .catch(function () {
                    // Ignore errors
                });
            });
        }
    };

    var buildHtml = function () {
        var outputDir = "build/web";

        return prepareWeb(outputDir)
        .then(function () { return prepareAssets(outputDir+"/assets", "html") })
        .then(function (assetFlags) {
            console.log("Building: " + outputDir);
            return buildJS({
                target: "html",
                outputDir: outputDir,
                assetFlags: assetFlags,
            });
        });
    };

    var buildFlash = function () {
        var swf = "build/web/targets/main-flash.swf";

        return prepareWeb()
        .then(function () { return prepareAssets("build/web/assets", "flash") })
        .then(function (assetFlags) {
            console.log("Building: " + swf);
            var flashFlags = swfFlags(false).concat([
            "-swf-version", SWF_VERSION, "-swf", swf]);
            return haxe(commonFlags.concat(assetFlags).concat(flashFlags));
        });
    };

    var buildAir = function (flags, platform) {
        var airFlags = swfFlags(true).concat(["-swf-version", "11.7", "-D", "air"]);

        wrench.mkdirSyncRecursive(CACHE_DIR+"air");
        return prepareAssets(CACHE_DIR+"air/assets", platform)
        .then(function (assetFlags) {
            return haxe(commonFlags.concat(assetFlags).concat(airFlags).concat(flags));
        });
    };

    var generateAirXml = function (swf, output) {
        var xml =
            "<application xmlns=\"http://ns.adobe.com/air/application/4.0\">\n" +
            "  <id>"+get(config, "id")+"</id>\n" +
            "  <versionNumber>"+get(config, "version")+"</versionNumber>\n" +
            "  <filename>"+get(config, "name")+"</filename>\n" +
            "  <initialWindow>\n" +
            "    <content>"+swf+"</content>\n" +
            "    <aspectRatio>"+get(config, "orientation", "portrait")+"</aspectRatio>\n" +
            "    <fullScreen>"+get(config, "fullscreen", "true")+"</fullScreen>\n" +
            "    <autoOrients>true</autoOrients>\n" + // Enables 180 degree rotation
            "    <renderMode>direct</renderMode>\n" +
            "  </initialWindow>\n" +
            "  <android>\n" +
            "    <manifestAdditions><![CDATA[\n" +
                   get(config, "android AndroidManifest.xml", "<manifest android:installLocation=\"auto\"/>") +
            "    ]]></manifestAdditions>\n" +
            "  </android>\n" +
            "  <iPhone>\n" +
            "    <InfoAdditions><![CDATA[\n" +
                   get(config, "ios Info.plist", "") +
            "    ]]></InfoAdditions>\n" +
            "    <Entitlements><![CDATA[\n" +
                   get(config, "ios Entitlements.plist", "") +
            "    ]]></Entitlements>\n" +
            "    <requestedDisplayResolution>high</requestedDisplayResolution>\n" +
            "  </iPhone>\n" +
            "</application>";
        var doc = new xmldom.DOMParser().parseFromString(xml);
        var pathOptions = []; // Path options to pass to ADT

        var extensions = doc.createElement("extensions");
        libPaths.forEach(function (libPath) {
            if (!fs.existsSync(libPath)) {
                return;
            }

            var hasANE = false;
            forEachFileIn(libPath, function (file) {
                if (file.match(/.*\.ane$/)) {
                    // Extract the extension ID from the .ane
                    var AdmZip = require("adm-zip");
                    var zip = new AdmZip(libPath+"/"+file);
                    var extension = new xmldom.DOMParser().parseFromString(
                        zip.readAsText("META-INF/ANE/extension.xml"));
                    var id = extension.getElementsByTagName("id")[0].textContent;

                    var extensionID = doc.createElement("extensionID");
                    extensionID.textContent = id;
                    extensions.appendChild(extensionID);
                    hasANE = true;
                }
            });
            if (hasANE) {
                pathOptions.push("-extdir", libPath);
            }
        });
        if (extensions.firstChild) {
            doc.documentElement.appendChild(extensions);
        }

        var icons = doc.createElement("icon");
        fs.readdirSync("icons").forEach(function (file) {
            // Only include properly named square icons
            var match = file.match(/^(\d+)x\1\.png$/);
            if (match) {
                var size = match[1];
                var image = doc.createElement("image"+size+"x"+size);
                image.textContent = "icons/"+file;
                icons.appendChild(image);
            } else {
                console.warn("Invalid icon: icons/"+file);
            }
        });
        if (icons.firstChild) {
            doc.documentElement.appendChild(icons);
            pathOptions.push("icons");
        }

        fs.writeFileSync(output, new xmldom.XMLSerializer().serializeToString(doc));
        return pathOptions;
    };

    var buildAndroid = function () {
        var apk = "build/main-android.apk";
        console.log("Building: " + apk);

        var swf = "main-android.swf";
        var cert = CACHE_DIR+"air/certificate-android.p12";
        var xml = CACHE_DIR+"air/config-android.xml";

        return buildAir(["-D", "android", "-swf", CACHE_DIR+"air/"+swf], "android")
        .then(function () {
            // Generate a dummy certificate if it doesn't exist
            if (!fs.existsSync(cert)) {
                return adt(["-certificate", "-cn", "SelfSign", "-validityPeriod", "25", "2048-RSA",
                    cert, "password"]);
            }
        })
        .then(function () {
            var pathOptions = generateAirXml(swf, xml);

            var androidFlags = ["-package"];
            if (debug) {
                var fdbHost = opts.fdbHost || getIP();
                androidFlags.push("-target", "apk-debug", "-connect", fdbHost);
            } else {
                androidFlags.push("-target", "apk-captive-runtime");
            }
            androidFlags.push("-storetype", "pkcs12", "-keystore", cert, "-storepass", "password",
                apk, xml);
            androidFlags = androidFlags.concat(pathOptions);
            androidFlags.push("-C", CACHE_DIR+"air", swf, "assets");
            if (fs.existsSync("android")) {
                androidFlags.push("-C", "android", ".");
            }
            return adt(androidFlags);
        });
    };

    var buildIos = function () {
        var ipa = "build/main-ios.ipa";
        console.log("Building: " + ipa);

        var swf = "main-ios.swf";
        var cert = "certs/ios-development.p12";
        var mobileProvision = "certs/ios.mobileprovision";
        var xml = CACHE_DIR+"air/config-ios.xml";

        return buildAir(["-D", "ios", "-D", "no-flash-override", "-swf", CACHE_DIR+"air/"+swf], "ios")
        .then(function () {
            var pathOptions = generateAirXml(swf, xml);

            var iosFlags = ["-package"];
            if (debug) {
                var fdbHost = opts.fdbHost || getIP();
                iosFlags.push("-target", "ipa-debug", "-connect", fdbHost);
            } else {
                iosFlags.push("-target", "ipa-ad-hoc");
            }
            // TODO(bruno): Make these cert options configurable
            iosFlags.push("-storetype", "pkcs12", "-keystore", cert, "-storepass", "password",
                "-provisioning-profile", mobileProvision, ipa, xml);
            iosFlags = iosFlags.concat(pathOptions);
            iosFlags.push("-C", CACHE_DIR+"air", swf, "assets");
            if (fs.existsSync("ios")) {
                iosFlags.push("-C", "ios", ".");
            }
            return adt(iosFlags);
        });
    };

    var buildFirefox = function () {
        var outputDir = "build/firefox";
        wrench.mkdirSyncRecursive(outputDir+"/targets");

        return prepareAssets(outputDir+"/assets", "firefox")
        .then(function (assetFlags) {
            console.log("Building: " + outputDir);
            return buildJS({
                target: "firefox",
                outputDir: outputDir,
                assetFlags: assetFlags,
            });
        })
        .then(function () {
            return copyDirs(DATA_DIR+"firefox", outputDir);
        })
        .then(function () {
            if (fs.existsSync("icons")) {
                return copyDirs("icons", outputDir+"/icons");
            }
        })
        .then(function () {
            var manifest = {
                name: get(config, "name"),
                description: get(config, "description"),
                developer: {
                    name: get(config, "developer name"),
                    url: get(config, "developer url"),
                },
                version: get(config, "version"),
                launch_path: "/index.html",
                orientation: get(config, "orientation", "portrait").toLowerCase() == "portrait" ?
                    ["portrait", "portrait-secondary"] : ["landscape", "landscape-secondary"],
                fullscreen: ""+get(config, "fullscreen", true),
                icons: {},
            };
            findIcons("icons").forEach(function (icon) {
                manifest.icons[icon.size] = "/"+icon.image;
            });

            // Copy any additional fields into manifest from 2DKit.yaml
            clone(get(config, "firefox manifest.webapp", {}), manifest);

            fs.writeFileSync(outputDir+"/manifest.webapp", JSON.stringify(manifest));
        });
    };

    wrench.mkdirSyncRecursive(CACHE_DIR);

    var connectFlags = ["--connect", opts.haxeServer || HAXE_COMPILER_PORT];
    return haxe(connectFlags, {check: false, verbose: false, output: false})
    .then(function (code) {
        // Use a Haxe compilation server if available
        if (code == 0) {
            commonFlags = commonFlags.concat(connectFlags);
        }

        commonFlags.push("-main", get(config, "main"));
        commonFlags = commonFlags.concat(toArray(get(config, "haxe_flags", [])));
        commonFlags.push("-lib", "flambe");
        srcPaths.forEach(function (srcDir) {
            commonFlags.push("-cp", srcDir);
        });
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
            ios: buildIos,
            firefox: buildFirefox,
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
        if ("SUDO_UID" in process.env && process.setuid) {
            // Drop back to normal user permissions if running through sudo
            process.setuid(parseInt(process.env["SUDO_UID"]));
        }
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
    opts = opts || {};
    opts.windowsCmd = false;
    return exec("haxe", flags, opts);
};
exports.haxe = haxe;

var haxelib = function (flags, opts) {
    return exec("haxelib", flags, opts);
};
exports.haxelib = haxelib;

var hxswfml = function (flags, opts) {
    return exec("neko " + BIN_DIR + "hxswfml.n", flags, opts);
};
exports.hxswfml = hxswfml;

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
    if (process.platform == "win32" && opts.windowsCmd !== false) {
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
    var flags = ["-jar", DATA_DIR+"closure.jar",
        "--warning_level", "QUIET",
        "--js_output_file", output,
        "--output_wrapper",
            "/** Cooked with Flambe, https://getflambe.com */\n" +
            "%output%"];
    inputs.forEach(function (input) {
        flags.push("--js", input);
    });
    if (opts.strict) flags.push("--language_in", "ES5_STRICT");
    return exec("java", flags, {verbose: false, windowsCmd: false});
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

var getHaxeFlags = function (config, platform) {
    if (platform == null) {
        platform = get(config, "default_platform", "flash");
    }
    checkPlatforms([platform]);

    var flags = [
        "-main", get(config, "main"),
        "-lib", "flambe",
        "-swf-version", SWF_VERSION,
        "-D", "flash-strict",
        "--no-output",
    ];

    switch (platform) {
    case "android": case "ios":
        flags.push("-D", "air");
        // Fall through
    case "flash":
        flags.push("-swf", "no-output.swf");
        break;
    default:
        flags.push("-js", "no-output.js");
        break;
    }
    if (platform != "flash") {
        flags.push("-D", platform);
    }

    flags = flags.concat(toArray(get(config, "haxe_flags", [])));
    getAllPaths(config, "src").forEach(function (srcPath) {
        flags.push("-cp", srcPath);
    });
    getAllPaths(config, "libs").forEach(function (libPath) {
        forEachFileIn(libPath, function (file) {
            flags.push("-swf-lib-extern", libPath+"/"+file);
        });
    });
    return flags;
}
exports.getHaxeFlags = getHaxeFlags;

var Server = function () {
};
exports.Server = Server;

Server.prototype.start = function () {
    var self = this;
    var connect = require("connect");
    var url = require("url");
    var websocket = require("websocket");

    // Fire up a Haxe compiler server, ignoring all output. It's fine if this command fails, the
    // build will fallback to not using a compiler server
    spawn("haxe", ["--wait", HAXE_COMPILER_PORT], {stdio: "ignore"});

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
    console.log("Serving on http://localhost:%s", HTTP_PORT);

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
    var fields = name.split(" ");
    for (var ii = 0, ll = fields.length; ii < ll; ++ii) {
        var field = fields[ii];
        if (field in config) {
            config = config[field];
            if (ii == ll-1) return config;
        }
    }
    if (typeof defaultValue != "undefined") return defaultValue;
    throw new Error("Missing required field in config file: " + name);
};

var getAllPaths = function (config, name) {
    var paths = toArray(get(config, "extra_paths "+name, []));
    if (paths.length == 0 || fs.existsSync(name)) {
        // Make the standard path in the project directory optional if you've defined extras
        paths.unshift(name);
    }
    return paths;
};

var checkPlatforms = function (platforms) {
    for (var ii = 0; ii < platforms.length; ++ii) {
        var platform = platforms[ii];
        if (exports.PLATFORMS.indexOf(platform) < 0) {
            throw new Error("Invalid platform: '" + platform + "'. Choose from " + exports.PLATFORMS.join(", ") + ".");
        }
    }
};

var copyDirs = function (dirs, dest, opts) {
    opts = opts || {};

    // Reverse it so files in earlier dirs have higher override priority
    dirs = toArray(dirs).reverse();

    var ncpOptions = {
        stopOnErr: true,
        filter: function (file) {
            return opts.includeHidden || path.basename(file).charAt(0) != ".";
        },
    };
    return dirs.reduce(function (prev, dir) {
        return prev.then(function () {
            return Q.nfcall(ncp, dir, dest, ncpOptions);
        });
    }, Q.nfcall(fs.mkdir, dest).catch(function (){}));
};

var copyFileSync = function (from, to) {
    var content = fs.readFileSync(from);
    fs.writeFileSync(to, content);
};

var forEachFileIn = function (dir, callback) {
    try {
        var files = fs.readdirSync(dir);
    } catch (error) {
        return; // Ignore missing directory
    }
    files.forEach(callback);
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

var clone = function (from, into) {
    into = into || {};
    for (var key in from) {
        into[key] = from[key];
    }
    return into;
};

var findIcons = function (dir) {
    var icons = [];
    fs.readdirSync(dir).forEach(function (file) {
        // Only include properly named square icons
        var match = file.match(/^(\d+)x\1\.png$/);
        if (match) {
            icons.push({
                size: match[1],
                image: dir+"/"+file,
            });
        }
        // TODO(bruno): Warn if not matched?
    });
    return icons;
};
