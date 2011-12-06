//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.asset.Manifest;
import flambe.platform.AppDriver;
import flambe.platform.Stage;
import flambe.platform.Storage;
import flambe.util.Signal1;

class System
{
    public static var root (default, null) :Entity;
    public static var driver (default, null) :AppDriver;

    public static var stage (getStage, null) :Stage;
    public static var storage (getStorage, null) :Storage;

    /**
     * Emitted when an uncaught exception occurs, if the platform supports it. You can wire this up
     * to your telemetry reporting service of choice.
     */
    public static var uncaughtError (default, null) :Signal1<String>;

    public static function init ()
    {
        root = new Entity();
        uncaughtError = new Signal1();

#if flash
        driver = new flambe.platform.flash.FlashAppDriver();
#elseif html
        driver = new flambe.platform.html.HtmlAppDriver();
#elseif amity
        driver = new flambe.platform.amity.AmityAppDriver();
#else
#error "Platform not supported!"
#end
        driver.init(root);
    }

    inline public static function loadAssetPack (manifest :Manifest)
    {
        return driver.loadAssetPack(manifest);
    }

    inline public static function callNative (funcName :String, ?params :Array<Dynamic>) :Dynamic
    {
        return driver.callNative(funcName, params);
    }

    inline private static function getStage () :Stage
    {
        return driver.getStage();
    }

    inline private static function getStorage () :Storage
    {
        return driver.getStorage();
    }
}
