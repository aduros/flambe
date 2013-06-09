//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.animation.AnimatedFloat;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.platform.Platform;
import flambe.subsystem.*;
import flambe.util.Assert;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.util.Signal1;
import flambe.util.Value;

/**
 * Provides access to all the different subsystems implemented on each platform.
 */
class System
{
    /**
     * The entity at the root of the hierarchy.
     */
    public static var root (default, null) :Entity = new Entity();

    /**
     * The Stage subsystem, for controlling the display viewport.
     */
    public static var stage (get, null) :StageSystem;

    /**
     * The Storage subsystem, for persisting values.
     */
    public static var storage (get, null) :StorageSystem;

    /**
     * The Pointer subsystem, for unified mouse/touch events.
     */
    public static var pointer (get, null) :PointerSystem;

    /**
     * The Mouse subsystem, for direct access to the mouse.
     */
    public static var mouse (get, null) :MouseSystem;

    /**
     * The Touch subsystem, for direct access to the multi-touch.
     */
    public static var touch (get, null) :TouchSystem;

    /**
     * The Keyboard subsystem, for keyboard events.
     */
    public static var keyboard (get, null) :KeyboardSystem;

    /**
     * The Web subsystem, for using the device's web browser.
     */
    public static var web (get, null) :WebSystem;

    /**
     * The External subsystem, for interaction with external code.
     */
    public static var external (get, null) :ExternalSystem;

    /**
     * The Motion subsystem, for events from the device's motion sensors.
     */
    public static var motion (get, null) :MotionSystem;

    // TODO(bruno): Subsystems for gamepads, haptic, geolocation, video, textInput

    /**
     * Gets the RFC 4646 language tag of the environment. For example, "en-US", "pt", or null if the
     * locale is unknown.
     */
    public static var locale (get, null) :String;

    /**
     * Emitted when an uncaught exception occurs, if the platform supports it. You can wire this up
     * to your telemetry reporting service of choice.
     */
    public static var uncaughtError (default, null) :Signal1<String> = new Signal1<String>();

    /**
     * True when the app is not currently visible, such as when minimized or placed in a background
     * browser tab. While hidden, frame updates may be paused or throttled.
     */
    public static var hidden (default, null) :Value<Bool> = new Value<Bool>(false);

    /**
     * Gets the current clock time, in <b>seconds</b> since January 1, 1970. Depending on the
     * platform, this may be slightly more efficient than Date.now().getTime().
     */
    public static var time (get, null) :Float;

    /**
     * <p>Whether the app currently has a GPU context. In some renderers (Stage3D) the GPU and all
     * its resources may be destroyed at any time by the system. On renderers that don't need to
     * worry about reclaiming GPU resources (HTML5 canvas) this is always true.</p>
     *
     * <p>When this becomes false, all Textures and Graphics objects are destroyed and become
     * invalid. When it returns to true, apps should reload its textures.</p>
     */
    public static var hasGPU (default, null) :Value<Bool> = new Value<Bool>(false);

    /**
     * The global volume applied to all sounds, defaults to 1.
     */
    public static var volume (default, null) :AnimatedFloat = new AnimatedFloat(1);

    /**
     * Starts up Flambe, this should usually be the first thing a game does.
     */
    public static function init ()
    {
        if (!_calledInit) {
            _platform.init();
            _calledInit = true;
        }
    }

    /**
     * Request to load an asset pack described by the given manifest.
     */
    inline public static function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        #if debug assertCalledInit(); #end
        return _platform.loadAssetPack(manifest);
    }

    /**
     * Creates a new blank Texture, initialized to transparent black.
     */
    public static function createTexture (width :Int, height :Int) :Texture
    {
#if debug
        assertCalledInit();
        var texture = _platform.getRenderer().createEmptyTexture(width, height);
        if (texture == null) {
            Log.warn("Failed to create texture. Is the GPU context unavailable?");
        }
        return texture;
#else
        return _platform.getRenderer().createEmptyTexture(width, height);
#end
    }

    /**
     * Creates a Logger for printing debug messages. In Flash, this uses the native trace()
     * function. In JS, logging goes to the console object. Logging is stripped from non-debug
     * builds.
     */
    inline public static function createLogger (tag :String) :Logger
    {
        // No need to assertCalledInit here, this should be callable from static initializers
        return new Logger(_platform.createLogHandler(tag));
    }

    inline private static function get_time () :Float
    {
        #if debug assertCalledInit(); #end
        return _platform.getTime();
    }

    inline private static function get_stage () :StageSystem
    {
        #if debug assertCalledInit(); #end
        return _platform.getStage();
    }

    inline private static function get_storage () :StorageSystem
    {
        #if debug assertCalledInit(); #end
        return _platform.getStorage();
    }

    inline private static function get_pointer () :PointerSystem
    {
        #if debug assertCalledInit(); #end
        return _platform.getPointer();
    }

    inline private static function get_mouse () :MouseSystem
    {
        #if debug assertCalledInit(); #end
        return _platform.getMouse();
    }

    inline private static function get_touch () :TouchSystem
    {
        #if debug assertCalledInit(); #end
        return _platform.getTouch();
    }

    inline private static function get_keyboard () :KeyboardSystem
    {
        #if debug assertCalledInit(); #end
        return _platform.getKeyboard();
    }

    inline private static function get_web () :WebSystem
    {
        #if debug assertCalledInit(); #end
        return _platform.getWeb();
    }

    inline private static function get_external () :ExternalSystem
    {
        #if debug assertCalledInit(); #end
        return _platform.getExternal();
    }

    inline private static function get_locale () :String
    {
        #if debug assertCalledInit(); #end
        return _platform.getLocale();
    }

    inline static function get_motion () :MotionSystem
    {
        #if debug assertCalledInit(); #end
        return _platform.getMotion();
    }

    private static function assertCalledInit ()
    {
        Assert.that(_calledInit, "You must call System.init() first");
    }

    private static var _platform :Platform =
#if flash
        flambe.platform.flash.FlashPlatform.instance;
#elseif html
        flambe.platform.html.HtmlPlatform.instance;
#else
        null;
#end

    private static var _calledInit = false;
}
