//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ThrottleEvent;
import flash.events.TouchEvent;
import flash.events.UncaughtErrorEvent;
import flash.external.ExternalInterface;
import flash.media.SoundMixer;
import flash.media.SoundTransform;
import flash.net.SharedObject;
import flash.system.Capabilities;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.subsystem.*;
import flambe.util.Logger;
import flambe.util.Promise;

class FlashPlatform
    implements Platform
{
    public static var instance (default, null) :FlashPlatform = new FlashPlatform();

    public var mainLoop (default, null) :MainLoop;

    private function new ()
    {
    }

    public function init ()
    {
        var stage = Lib.current.stage;
        var promise = new Promise<Bool>();
        promise.success.connect(function (result) {
            Log.info("Initialized Flash platform", ["renderer", _renderer.type]);
        });

        _stage = new FlashStage(stage);
        _pointer = new BasicPointer();
        _mouse = FlashMouse.shouldUse() ? new FlashMouse(_pointer, stage) : new DummyMouse();
#if air
        _touch = AirTouch.shouldUse() ? new AirTouch(_pointer, stage) : new DummyTouch();
#else
        _touch = new DummyTouch();
#end

        var stage3DRenderer = new Stage3DRenderer();
        _renderer = stage3DRenderer;
        stage3DRenderer.promise.success.connect(function (result) {
            // Stage3DRenderer's initialization is the only asynchronous part of FlashPlatform's init
            promise.result = result;
        });
        mainLoop = new MainLoop();

        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(Event.RENDER, onRender);

        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(
            UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

        // TODO(bruno): Get the currently visible state when the app starts?
#if air
        stage.addEventListener(Event.ACTIVATE, onActivate);
        stage.addEventListener(Event.DEACTIVATE, onActivate);
#else
        // DEACTIVATE is fired when the Flash embed loses focus, so use throttle events in the
        // browser instead to detect when the tab gets backgrounded
        stage.addEventListener(ThrottleEvent.THROTTLE, onThrottle);
#end
        System.hidden.changed.connect(function (hidden,_) {
            if (!hidden) {
                _skipFrame = true;
            }
        });

// #if air
//         // Ensure sound stops when the app is backgrounded or hardware muted on iOS
//         SoundMixer.audioPlaybackMode = "ambient";
// #end

#if !air
        // Hack to fix SharedObject in Chrome Flash:
        // https://groups.google.com/forum/#!topic/flambe/aD6KUvORWks
        getStorage();
#end

        System.volume.watch(function (volume, _) {
            var s = SoundMixer.soundTransform;
            s.volume = volume;
            SoundMixer.soundTransform = s;
        });

        _lastUpdate = Lib.getTimer();
        _skipFrame = false;
        _timeOffset = Date.now().getTime() - Lib.getTimer();

#if debug
        new DebugLogic(this);
        _catapult = FlashCatapultClient.canUse() ? new FlashCatapultClient() : null;
#end
        return promise;
    }

    public function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return new FlashAssetPackLoader(this, manifest).promise;
    }

    public function getStage () :StageSystem
    {
        return _stage;
    }

    public function getStorage () :StorageSystem
    {
        if (_storage == null) {
            try {
                _storage = new FlashStorage(SharedObject.getLocal("flambe"));
            } catch (err :Dynamic) {
                // SharedObject.getLocal may throw an error
                Log.warn("SharedObject is unavailable, falling back to unpersisted storage");
                _storage = new DummyStorage();
            }
        }
        return _storage;
    }

    public function getPointer () :PointerSystem
    {
        return _pointer;
    }

    public function getMouse () :MouseSystem
    {
        return _mouse;
    }

    public function getTouch () :TouchSystem
    {
        return _touch;
    }

    public function getKeyboard () :KeyboardSystem
    {
        if (_keyboard == null) {
            _keyboard = FlashKeyboard.shouldUse() ?
                new FlashKeyboard(_stage.nativeStage) : new DummyKeyboard();
        }
        return _keyboard;
    }

    public function getWeb () :WebSystem
    {
        if (_web == null) {
#if air
            if (AirWeb.shouldUse()) {
                _web = new AirWeb(_stage.nativeStage);
            } else {
                Log.warn("StageWebView is unavailable");
                _web = new FlashWeb();
            }
#else
            _web = new FlashWeb();
#end
        }
        return _web;
    }

    public function getExternal () :ExternalSystem
    {
        if (_external == null) {
            _external = FlashExternal.shouldUse() ? new FlashExternal() : new DummyExternal();
        }
        return _external;
    }

    public function getMotion () :MotionSystem
    {
        if (_motion == null) {
#if air
            if (AirMotion.shouldUse()) {
                _motion = new AirMotion();
            } else {
                Log.warn("Accelerometer is unavailable");
                _motion = new DummyMotion();
            }
#else
            _motion = new DummyMotion();
#end
        }
        return _motion;
    }

    public function getRenderer () :Stage3DRenderer
    {
        return _renderer;
    }

    public function getLocale () :String
    {
        return Capabilities.language;
    }

    public function createLogHandler (tag :String) :LogHandler
    {
#if (debug || flambe_keep_logs)
        return new FlashLogHandler(tag);
#else
        return null;
#end
    }

    public function getTime () :Float
    {
        return (_timeOffset+Lib.getTimer()) / 1000;
    }

    public function getCatapultClient ()
    {
        return _catapult;
    }

    private function onEnterFrame (_)
    {
        var now = Lib.getTimer();
        var dt = (now-_lastUpdate) / 1000;
        _lastUpdate = now;

        if (System.hidden._) {
            return; // Prevent updates while hidden
        }
        if (_skipFrame) {
            _skipFrame = false;
            return;
        }

        mainLoop.update(dt);
        Lib.current.stage.invalidate();
    }

    private function onRender (_)
    {
        mainLoop.render(_renderer);
    }

    private function onUncaughtError (event :UncaughtErrorEvent)
    {
        System.uncaughtError.emit(FlashUtil.getErrorMessage(event.error));
    }

    private function onActivate (event :Event)
    {
        System.hidden._ = (event.type == Event.DEACTIVATE);
    }

    private function onThrottle (event :ThrottleEvent)
    {
        System.hidden._ = (event.state != "resume");
    }

    // Statically initialized subsystems
    private var _mouse :MouseSystem;
    private var _pointer :BasicPointer;
    private var _renderer :Stage3DRenderer;
    private var _stage :FlashStage;
    private var _touch :TouchSystem;

    // Lazily initialized subsystems
    private var _external :ExternalSystem;
    private var _keyboard :KeyboardSystem;
    private var _motion :MotionSystem;
    private var _storage :StorageSystem;
    private var _web :WebSystem;

    private var _lastUpdate :Int;
    private var _skipFrame :Bool;
    private var _timeOffset :Float;

    private var _catapult :FlashCatapultClient;
}
