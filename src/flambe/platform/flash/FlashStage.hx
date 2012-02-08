//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.Video;
import flash.system.Capabilities;

import flambe.platform.Stage;
import flambe.util.Signal0;

class FlashStage implements Stage
{
    public var width (getWidth, null) :Int;
    public var height (getHeight, null) :Int;

    public var resize (default, null) :Signal0;

    public function new (stage :flash.display.Stage)
    {
        _stage = stage;
        resize = new Signal0();

        _stage.scaleMode = NO_SCALE;
        _stage.showDefaultContextMenu = false;
        _stage.addEventListener(Event.RESIZE, onResize);

        // If we're running in a mobile browser, go full screen on a pointer event
        if (Capabilities.playerType == "PlugIn" && FlashUtil.isMobile()) {
            _stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        }
    }

    public function getWidth () :Int
    {
        return _stage.stageWidth;
    }

    public function getHeight () :Int
    {
        return _stage.stageHeight;
    }

    public function lockOrientation (orient :Orientation)
    {
        if (!FlashUtil.isMobile()) {
            return;
        }
        if (orient == null) {
            if (_orientHack != null) {
                _orientHack.parent.removeChild(_orientHack);
                _orientHack = null;
            }
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
                _stage.addChild(_orientHack);
            }
        }
    }

    private function onMouseDown (_)
    {
        _stage.displayState = FULL_SCREEN;
    }

    private function onResize (_)
    {
        resize.emit();
    }

    private var _stage :flash.display.Stage;
    private var _orientHack :Video;
}
