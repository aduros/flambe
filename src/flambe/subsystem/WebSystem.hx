//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.subsystem;

import flambe.web.WebView;

/**
 * Functions related to the environment's web browser.
 */
interface WebSystem
{
    /**
     * True if the environment supports WebViews. Note that this will always be false on the browser
     * Flash target.
     */
    var supported (get, null) :Bool;

    /**
     * Creates a blank WebView with the given viewport bounds, in pixels. Fails with an assertion if
     * this environment doesn't support WebViews.
     */
    function createView (x :Float, y :Float, width :Float, height :Float) :WebView;

    /**
     * Open a new browser window or tab to the given URL. This operation is always supported. URI
     * schemes such as mailto: are also available. On mobile, sms: and tel: are supported. On
     * Android, market: is supported.
     */
    function openBrowser (url :String) :Void;
}
