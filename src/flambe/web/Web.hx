//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.web;

/**
 * Functions related to the environment's web browser.
 */
interface Web
{
    /**
     * True if the environment supports WebViews. Note that this will always be false on the browser
     * Flash target.
     */
    var supported (isSupported, null) :Bool;

    /**
     * Creates a blank WebView with the given viewport bounds, in pixels. Fails with an assertion if
     * this environment doesn't support WebViews.
     */
    function createView (x :Float, y :Float, width :Float, height :Float) :WebView;

    // function openBrowser (url :String);
}
