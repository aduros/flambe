//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nme;

#if flambe_air
import flash.events.StageOrientationEvent;
#end
import nme.display.StageDisplayState;
import nme.events.Event;
import nme.events.FullScreenEvent;
import nme.events.MouseEvent;
//import nme.media.Video;
import nme.system.Capabilities;

import flambe.display.Orientation;
import flambe.display.Stage;
import flambe.util.Signal0;
import flambe.util.Value;

class NMEStage
    implements Stage
{
    private static var log = Log.log; // http://code.google.com/p/haxe/issues/detail?id=365

    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;
    public var orientation (default, null) :Value<Orientation>;
    public var fullscreen (default, null) :Value<Bool>;
    public var fullscreenSupported (isFullscreenSupported, null) :Bool;

    public var resize (default, null) :Signal0;

    public var nativeStage (default, null) :nme.display.Stage;

    public function new (nativeStage :nme.display.Stage)
    {
        this.nativeStage = nativeStage;
        resize = new Signal0();

        nativeStage.scaleMode = NO_SCALE;
        nativeStage.frameRate = 60;
        nativeStage.showDefaultContextMenu = false;
        nativeStage.addEventListener(Event.RESIZE, onResize);

        fullscreen = new Value<Bool>(false);
        nativeStage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
        onFullscreen();

        // If we're running in a mobile browser, go full screen on a pointer event
        if (Capabilities.playerType == "PlugIn" && NMEUtil.isMobile()) {
            nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        }

        orientation = new Value<Orientation>(null);
#if flambe_air
        nativeStage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);
        onOrientationChange();
#end
    }

    public function getWidth () :Int
    {
        return nativeStage.stageWidth;
    }

    public function getHeight () :Int
    {
        return nativeStage.stageHeight;
    }

    public function isFullscreenSupported () :Bool
    {
#if flash10_2
        return nativeStage.allowsFullScreen;
#else
        return true;
#end
    }

#if flambe_air
    public function lockOrientation (orient :Orientation)
    {
        nativeStage.autoOrients = true;
        nativeStage.setAspectRatio(NMEUtil.aspectRatio(orient));
    }

    public function unlockOrientation ()
    {
        nativeStage.autoOrients = true;
        nativeStage.setAspectRatio(cast "any"); // ANY is undefined, WTF?
    }

    private function onOrientationChange (?_)
    {
        // Maybe this should be nativeStage.deviceOrientation, but deviceOrientation doesn't change
        // after a lockOrientation()
        orientation._ = NMEUtil.orientation(nativeStage.orientation);
    }

#else
    public function lockOrientation (orient :Orientation)
    {
        if (!NMEUtil.isMobile()) {
            return;
        }

        // http://www.kongregate.com/pages/flash-sizing-zen#device_orientation
        // Only works in full screen. AIR has something less whack, but this works in the browser
        switch (orient) {
        case Portrait:
            // Unimplemented
        case Landscape:
            /*if (_orientHack == null) {
                _orientHack = new Video(0, 0);
                _orientHack.visible = false;
                nativeStage.addChild(_orientHack);
            }*/
        }
    }

    public function unlockOrientation ()
    {
        if (_orientHack != null) {
            _orientHack.parent.removeChild(_orientHack);
            _orientHack = null;
        }
    }

    //private var _orientHack :Video;
#end

    public function requestResize (width :Int, height :Int)
    {
        // Not supported
    }

    public function requestFullscreen (enable :Bool = true)
    {
        // Use FULL_SCREEN_INTERACTIVE instead?
        try {
            nativeStage.displayState = enable ? FULL_SCREEN : NORMAL;
        } catch (error :Dynamic) {
            log.warn("Error when changing fullscreen", ["enable", enable,
                "error", NMEUtil.getErrorMessage(error)]);
        }
    }

    private function onMouseDown (_)
    {
        requestFullscreen(true);
    }

    private function onResize (_)
    {
        resize.emit();
    }

    private function onFullscreen (?_)
    {
        fullscreen._ = (nativeStage.displayState != NORMAL);
    }
}
