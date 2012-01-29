/**
 * A helper for embedding Flambe games in a browser that smartly chooses either the Flash or HTML
 * platform based on what the browser best supports.
 *
 * For testing, you can use URL query ?flambe-platform=flash (or =html) to force the use of a
 * specific platform.
 */
var flambe = (function () {
    return {
        embed: function (urls, elementId, width, height) {

            // TODO(bruno): Allow you to order the URLs array based on preference. For now the swf
            // must be first and the JS second.
            if (typeof urls == "string") {
                urls = [ urls + "-flash.swf", urls + "-html.js" ];
            }

            var args = {};
            var pairs = window.location.search.substr(1).split("&");
            for (var ii = 0; ii < pairs.length; ++ii) {
                var pair = pairs[ii].split("=");
                args[unescape(pair[0])] = (pair.length > 1) ? unescape(pair[1]) : null;
            }

            var pref = args["flambe-platform"];
            var flashVersion = "10";

            if ((pref == null || pref == "flash")
                    && swfobject.hasFlashPlayerVersion(flashVersion)) {
                swfobject.embedSWF(urls[0], elementId,
                    Math.min(window.innerWidth, width),
                    Math.min(window.innerHeight, height),
                    flashVersion, null, {}, {
                        allowScriptAccess: "always",
                        allowFullScreen: "true",
                        fullscreenOnSelection: "true"
                    });

            } else if (pref == null || pref == "html") {
                var canvas = document.createElement("canvas");
                if ("getContext" in canvas) {
                    var repack = function () {
                        canvas.width = Math.min(window.innerWidth, width);
                        canvas.height = Math.min(window.innerHeight, height);
                    };
                    repack();
                    window.addEventListener("resize", repack, false);

                    var content = document.getElementById(elementId);
                    content.appendChild(canvas);

                    // Expose the canvas so haXe can use it
                    flambe.canvas = canvas;

                    var script = document.createElement("script");
                    script.onload = function () {
                        flambe.canvas = null;
                        repack();
                    };
                    script.src = urls[1];
                    content.appendChild(script);
                }

            } else {
                throw new Error("Unrecognized platform: " + pref);
            }
        }
    };
})();
