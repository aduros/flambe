//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display3D.Context3D;
import flash.display.BitmapData;
import flash.display.Stage3D;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;

import flambe.display.DrawingContext;
import flambe.display.Texture;

class Stage3DRenderer
    implements Renderer
{
    public function new ()
    {
        _textures = [];

        // Use the first available Stage3D
        var stage = Lib.current.stage;
        for (stage3D in stage.stage3Ds) {
            if (stage3D.context3D == null) {
                stage.addEventListener(Event.RESIZE, onResize);

                stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
                stage3D.addEventListener(ErrorEvent.ERROR, onError);
                stage3D.requestContext3D();
                return;
            }
        }

        Log.error("No free Stage3Ds available!");
    }

    public function createTexture (bitmapData :Dynamic) :Texture
    {
        var texture = new Stage3DTexture(cast bitmapData);
        _textures.push(texture);
        uploadToContext3D(texture);
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

    private function uploadToContext3D (texture :Stage3DTexture)
    {
        var bitmapData = texture.bitmapData;

        // Use a resized copy if necessary
        var w2 = nextPowerOfTwo(bitmapData.width);
        var h2 = nextPowerOfTwo(bitmapData.height);

        texture.maxU = bitmapData.width / w2;
        texture.maxV = bitmapData.height / h2;

        if (bitmapData.width != w2 || bitmapData.height != h2) {
            // Resize up to the next power of two, padding with transparent black
            var resized = new BitmapData(w2, h2, true, 0x00000000);
            resized.copyPixels(bitmapData,
                new Rectangle(0, 0, bitmapData.width, bitmapData.height), new Point(0, 0));
            bitmapData = resized;
        }

        // TODO(bruno): Look into compressed textures
        var nativeTexture = _context3D.createTexture(
            bitmapData.width, bitmapData.height, BGRA, false);

        // TODO(bruno): Upload different mip maps?
        nativeTexture.uploadFromBitmapData(bitmapData);

        texture.nativeTexture = nativeTexture;
    }

    private function onContext3DCreate (event :Event)
    {
        var stage3D :Stage3D = event.target;
        _context3D = stage3D.context3D;

        Log.info("Created new Stage3D context", ["driver", _context3D.driverInfo]);

        // Re-upload any lost textures to the GPU
        for (texture in _textures) {
            uploadToContext3D(texture);
        }

        _drawCtx = new Stage3DDrawingContext(_context3D);
        onResize(null);
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

    private static function nextPowerOfTwo (n :Int)
    {
        var p = 1;
        while (p < n) {
            p <<= 1;
        }
        return p;
    }

    private var _drawCtx :Stage3DDrawingContext;
    private var _context3D :Context3D;

    private var _textures :Array<Stage3DTexture>;
}
