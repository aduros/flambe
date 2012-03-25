/**
 * A helper for embedding Flambe games in a browser that smartly chooses either the Flash or HTML
 * platform based on what the browser best supports.
 *
 * For testing, you can use URL query ?flambe-platform=flash (or =html) to force the use of a
 * specific platform.
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
flambe.embed = function (urls, elementId) {

    if (typeof urls == "string") {
        urls = [ urls + "-flash.swf", urls + "-html.js" ];
    }

    var container = document.getElementById(elementId);
    if (container == null) {
        throw new Error("Could not find element: " + elementId);
    }

    var args = {};
    var pairs = window.location.search.substr(1).split("&");
    for (var ii = 0; ii < pairs.length; ++ii) {
        var pair = pairs[ii].split("=");
        args[unescape(pair[0])] = (pair.length > 1) ? unescape(pair[1]) : null;
    }

    var pref = args["flambe-platform"];

    for (var ii = 0; ii < urls.length; ++ii) {
        var url = urls[ii];
        var ext = url.match(/\.(\w+)[\?#$]/);
        if (ext) {
            ext = ext[1].toLowerCase();
        }

        if (ext == "swf" && (pref == null || pref == "flash")
                && swfobject.hasFlashPlayerVersion(flambe.FLASH_VERSION)) {

            // SWFObject replaces the element it's given, so create a temporary inner element
            // for parity with JS
            var swf = document.createElement("div");
            swf.id = elementId + "-swf";
            container.appendChild(swf);

            swfobject.embedSWF(url, swf.id, "100%", "100%", flambe.FLASH_VERSION, null, {}, {
                allowScriptAccess: "always",
                allowFullScreen: "true",
                fullscreenOnSelection: "true",
                wmode: "direct"
            });
            return true;

        } else if (ext == "js" && (pref == null || pref == "html")) {
            var canvas = document.createElement("canvas");
            if ("getContext" in canvas) {
                canvas.id = elementId + "-canvas";
                container.appendChild(canvas);

                // Expose the canvas so haXe can use it
                flambe.canvas = canvas;

                var script = document.createElement("script");
                script.onload = function () {
                    flambe.canvas = null;
                };
                script.src = url;
                container.appendChild(script);
                return true;
            }

        } else if (pref == null) {
            throw new Error("Don't know how to embed: " + url);
        }
    }

    // Nothing was embedded!
    return false;
};
