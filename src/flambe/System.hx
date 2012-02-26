//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.input.Keyboard;
import flambe.input.Pointer;
import flambe.platform.AppDriver;
import flambe.platform.Stage;
import flambe.platform.Storage;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.util.Signal1;

// import flambe.Log;

#if (!flash && !html)
#error "Platform not supported!"
#end

class System
{
    public static var root (default, null) :Entity;
    public static var driver (default, null) :AppDriver;

    public static var stage (getStage, null) :Stage;

    public static var storage (getStorage, null) :Storage;

    public static var pointer (getPointer, null) :Pointer;

    public static var keyboard (getKeyboard, null) :Keyboard;

    public static var locale (getLocale, null) :String;

    // TODO(bruno): mouse, touch, accelerometer, gamepads, haptic, geolocation, video, web,
    // textInput

    /**
     * Emitted when an uncaught exception occurs, if the platform supports it. You can wire this up
     * to your telemetry reporting service of choice.
     */
    public static var uncaughtError (default, null) :Signal1<String>;

    // A bunch of short-hands to driver functions

    inline public static function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return driver.loadAssetPack(manifest);
    }

    inline public static function callNative (funcName :String, ?params :Array<Dynamic>) :Dynamic
    {
        return driver.callNative(funcName, params);
    }

    inline public static function logger (tag :String) :Logger
    {
        return new Logger(driver.createLogHandler(tag));
    }

    inline private static function getStage () :Stage
    {
        return driver.stage;
    }

    inline private static function getStorage () :Storage
    {
        return driver.storage;
    }

    inline private static function getPointer () :Pointer
    {
        return driver.pointer;
    }

    inline private static function getKeyboard () :Keyboard
    {
        return driver.keyboard;
    }

    inline private static function getLocale () :String
    {
        return driver.locale;
    }

    private static var _static_init = (function () {
        root = new Entity();
        uncaughtError = new Signal1();

#if flash
        driver = flambe.platform.flash.FlashAppDriver.getInstance();
#elseif html
        driver = flambe.platform.html.HtmlAppDriver.getInstance();
#end
        return false;
    })();
}
