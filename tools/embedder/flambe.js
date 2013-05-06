/**
 * A helper for embedding Flambe games in a browser that smartly chooses either the Flash or HTML
 * platform based on what the browser best supports.
 *
 * For testing, you can use URL query ?flambe=flash (or =html) to force the use of a specific
 * platform.
 */
var flambe = {};

/** @define {string} */
flambe.FLASH_VERSION = "10.1";

/**
 * Embed a Flambe game into the page.
 *
 * @return True if the game was successfully embedded. False if the browser doesn't have a
 *     recent enough browser or Flash player.
 */
flambe.embed = function (urls, elementId, callback) {

    if (typeof urls == "string") {
        urls = [ urls + "-flash.swf", urls + "-html.js" ];
    }

    var container = document.getElementById(elementId);
    if (container == null) {
        throw new Error("Could not find element [id=" + elementId + "]");
    }

    var args = {};
    var pairs = window.location.search.substr(1).split("&");
    for (var ii = 0; ii < pairs.length; ++ii) {
        var pair = pairs[ii].split("=");
        args[unescape(pair[0])] = (pair.length > 1) ? unescape(pair[1]) : null;
    }

    var pref = args["flambe"];

    for (var ii = 0; ii < urls.length; ++ii) {
        var url = urls[ii];
        var ext = url.match(/\.(\w+)(\?|$)/);
        if (ext) {
            ext = ext[1].toLowerCase();
        }

        switch (ext) {
        case "swf":
            if ((pref == null || pref == "flash")
                    && swfobject.hasFlashPlayerVersion(flambe.FLASH_VERSION)) {

                // SWFObject replaces the element it's given, so create a temporary inner element
                // for parity with JS
                var swf = document.createElement("div");
                swf.id = elementId + "-swf";
                container.appendChild(swf);

                // Setup the helper for binding global functions
                if (typeof $flambe_expose == "undefined") {
                    window.$flambe_expose = function (name, objectId) {
                        window[name] = (objectId != null) ? function () {
                            var swf = document.getElementById(objectId);
                            swf[name].apply(swf, arguments);
                        } : null;
                    };
                }

                swfobject.embedSWF(url, swf.id, "100%", "100%", flambe.FLASH_VERSION, null, {}, {
                    allowScriptAccess: "always",
                    allowFullScreen: "true",
                    fullscreenOnSelection: "true",
                    wmode: "direct"
                }, {
                    id: swf.id,
                    name: swf.id
                }, function(e) {
                    if(callback)
                        callback(e.success);
                });
                return true;
            }
            break;

        case "js":
            if (pref == null || pref == "html") {
                var canvas = document.createElement("canvas");
                if ("getContext" in canvas) {
                    canvas.id = elementId + "-canvas";
                    // Force a width and height of 0 to prevent some user agents assigning a default width/height
                    canvas.width = 0;
                    canvas.height = 0;
                    container.appendChild(canvas);

                    // Expose the canvas so Haxe can use it
                    flambe.canvas = canvas;

                    var script = document.createElement("script");
                    script.onerror = function() {
                        flambe.canvas = null;
                        if(callback)
                            callback(false);
                    };
                    script.onload = function () {
                        flambe.canvas = null;
                        if(callback)
                            callback(true);
                    };
                    script.src = url;
                    container.appendChild(script);

                    return true;
                }
            }
            break;

        default:
            throw new Error("Don't know how to embed [url=" + url + "]");
        }
    }

    // Nothing was embedded!
    return false;
};
