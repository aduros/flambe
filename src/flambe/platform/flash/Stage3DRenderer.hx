//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display3D.Context3D;
import flash.display.BitmapData;
import flash.display.Stage3D;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.Lib;

import flambe.display.DrawingContext;
import flambe.display.Texture;

class Stage3DRenderer
    implements Renderer
{
    public function new ()
    {
        // Use the first available Stage3D
        var stage = Lib.current.stage;
        for (stage3D in stage.stage3Ds) {
            if (stage3D.context3D == null) {
                stage.addEventListener(Event.RESIZE, onResize);

                stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
                stage3D.addEventListener(ErrorEvent.ERROR, onError);

                // The constrained profile is only available in 11.4
                if ((untyped stage3D).requestContext3D.length >= 2) {
                    (untyped stage3D).requestContext3D("auto", "baselineConstrained");
                } else {
                    stage3D.requestContext3D();
                }
                return;
            }
        }

        Log.error("No free Stage3Ds available!");
    }

    public function createTexture (bitmapData :Dynamic) :Texture
    {
        var bitmapData :BitmapData = cast bitmapData;
        var texture = new Stage3DTexture(bitmapData.width, bitmapData.height);
        texture.init(_context3D, false);
        texture.uploadBitmapData(bitmapData);
        return texture;
    }

    public function createEmptyTexture (width :Int, height :Int) :Texture
    {
        var texture = new Stage3DTexture(width, height);
        texture.init(_context3D, true);
        return texture;
    }

    public function willRender () :DrawingContext
    {
        if (_drawCtx == null) {
            return null;
        }
        _drawCtx.willRender();
        return _drawCtx;
    }

    public function didRender ()
    {
        _drawCtx.didRender();
    }

    private function onContext3DCreate (event :Event)
    {
        var stage3D :Stage3D = event.target;
        var contextLost = _context3D != null;
        _context3D = stage3D.context3D;

        Log.info("Created new Stage3D context", ["driver", _context3D.driverInfo]);

        _drawCtx = new Stage3DDrawingContext(_context3D);
        onResize(null);

        if (contextLost) {
            // TODO(bruno): Emit a signal so the game can handle it
        }
    }

    private function onError (event :ErrorEvent)
    {
        Log.error("Unexpected Stage3D failure!", ["error", event.text]);
    }

    private function onResize (_)
    {
        if (_drawCtx != null) {
            var stage = Lib.current.stage;
            _drawCtx.resize(stage.stageWidth, stage.stageHeight);
        }
    }

    private var _drawCtx :Stage3DDrawingContext;
    private var _context3D :Context3D;
}
