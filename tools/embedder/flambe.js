/**
 * A helper for embedding Flambe games in a browser that smartly chooses either the Flash or HTML
 * platform based on what the browser best supports.
 *
 * For testing, you can use URL query ?flambe-platform=flash (or =html) to force the use of a
 * specific platform.
 */
var flambe = (function () {
    return {
        embed: function (appName, elementId, width, height) {
            width = Math.min(window.innerWidth, width);
            height = Math.min(window.innerHeight, height);

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
                swfobject.embedSWF(appName + ".swf", elementId,
                    width, height, flashVersion, null, {}, {
                        fullscreenOnSelection: "true"
                    });

            } else if (pref == null || pref == "html") {
                var canvas = document.createElement("canvas");
                if ("getContext" in canvas) {
                    canvas.width = width;
                    canvas.height = height;

                    // Browser optimization hints
                    canvas.setAttribute("moz-opaque", "true");
                    // canvas.style.webkitTransform = "translateZ(0)";
                    // canvas.style.backgroundColor = "#000";

                    var content = document.getElementById(elementId);
                    content.appendChild(canvas);

                    // Expose the canvas so haXe can use it
                    flambe.canvas = canvas;

                    var script = document.createElement("script");
                    script.onload = function () {
                        flambe.canvas = null;
                    };
                    script.src = appName + "-html.js";
                    content.appendChild(script);
                }

            } else {
                throw new Error("Unrecognized platform: " + pref);
            }

            // Hide the chrome on mobile browsers. Sometimes.
            window.scrollTo(0, 1);
        }
    };
})();
