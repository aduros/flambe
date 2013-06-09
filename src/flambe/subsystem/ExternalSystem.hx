//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.subsystem;

import flambe.util.Disposable;

/**
 * Functions for interacting with external code. When running in a web browser, this means
 * Javascript running on the page.
 */
interface ExternalSystem
{
    /**
     * Whether the environment supports interaction with external code.
     */
    var supported (get, null) :Bool;

    /**
     * Call an external function with the given parameters, and returns the result. Errors thrown by
     * the called function will propogate.
     */
    function call (name :String, ?params :Array<Dynamic>) :Dynamic;

    /**
     * Bind a function to be called by external code.
     * @param name The name to bind to. The namespace may be shared with third party code, so it's
     *   good practice to prefix names. In Javascript, the function will be hooked onto the window
     *   object.
     * @param fn The function, or null to unbind.
     */
    function bind (name :String, fn :Dynamic) :Void;
}
