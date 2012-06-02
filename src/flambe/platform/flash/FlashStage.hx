//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.Video;
import flash.system.Capabilities;

import flambe.display.Orientation;
import flambe.display.Stage;
import flambe.util.Signal0;

class FlashStage
    implements Stage
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;

    public var resize (default, null) :Signal0;

    public function new (nativeStage :flash.display.Stage)
    {
        _nativeStage = nativeStage;
        resize = new Signal0();

        _nativeStage.scaleMode = NO_SCALE;
        _nativeStage.frameRate = 60;
        _nativeStage.showDefaultContextMenu = false;
        _nativeStage.addEventListener(Event.RESIZE, onResize);

        // If we're running in a mobile browser, go full screen on a pointer event
        if (Capabilities.playerType == "PlugIn" && FlashUtil.isMobile()) {
            _nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        }
    }

    public function getWidth () :Int
    {
        return _nativeStage.stageWidth;
    }

    public function getHeight () :Int
    {
        return _nativeStage.stageHeight;
    }

    public function lockOrientation (orient :Orientation)
    {
        if (!FlashUtil.isMobile()) {
            return;
        }

        // http://www.kongregate.com/pages/flash-sizing-zen#device_orientation
        // Only works in full screen. AIR has something less whack, but this works in the browser
        switch (orient) {
        case Portrait:
            // Unimplemented
        case Landscape:
            if (_orientHack == null) {
                _orientHack = new Video(0, 0);
                _orientHack.visible = false;
                _nativeStage.addChild(_orientHack);
            }
        }
    }

    public function unlockOrientation ()
    {
        if (_orientHack != null) {
            _orientHack.parent.removeChild(_orientHack);
            _orientHack = null;
        }
    }

    public function requestResize (width :Int, height :Int)
    {
        // Not supported
    }

    private function onMouseDown (_)
    {
        _nativeStage.displayState = FULL_SCREEN;
    }

    private function onResize (_)
    {
        resize.emit();
    }

    private var _nativeStage :flash.display.Stage;
    private var _orientHack :Video;
}
