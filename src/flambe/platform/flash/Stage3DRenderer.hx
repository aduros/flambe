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
        _events = new EventGroup();
    }

    public function uploadTexture (texture :Texture)
    {
        var flashTexture = cast texture;
        _textures.push(flashTexture);
        uploadToContext3D(flashTexture);
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

    public function init ()
    {
        var stage = Lib.current.stage;

        // Use the first available Stage3D
        for (stage3D in stage.stage3Ds) {
            if (stage3D.context3D == null) {
                _events.addListener(stage, Event.RESIZE, onResize);

                _stage3D = stage3D;
                _events.addListener(_stage3D, Event.CONTEXT3D_CREATE, onContext3DCreate);
                _events.addDisposingListener(_stage3D, ErrorEvent.ERROR, onError);
                _stage3D.requestContext3D();
                return;
            }
        }

        Log.warn("No free Stage3Ds available");
        onError();
    }

    private function uploadToContext3D (texture :FlashTexture)
    {
        var bitmapData = texture.bitmapData;

        // Use a resized copy if necessary
        var w2 = nextPowerOfTwo(bitmapData.width);
        var h2 = nextPowerOfTwo(bitmapData.height);

        texture.maxU = bitmapData.width / w2;
        texture.maxV = bitmapData.height / h2;

        if (bitmapData.width != w2 || bitmapData.height != h2) {
            // Resize up to the next power of two, padding with transparent black
            var resized = new BitmapData(w2, h2, bitmapData.transparent, 0x00000000);
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

#if !flambe_debug_renderer
        // BitmapRenderer is faster than carrying on with a software driver
        if (_context3D.driverInfo.indexOf("Software") != -1) {
            Log.warn("Detected a slow Stage3D driver, refusing to go on");
            var ref = _context3D;
            onError();
            ref.dispose();
            return;
        }
#end

        // Re-upload any lost textures to the GPU
        for (texture in _textures) {
            uploadToContext3D(texture);
        }

        _drawCtx = new Stage3DDrawingContext(_context3D);
        onResize(null);
    }

    private function onError (?event :ErrorEvent)
    {
        _events.dispose();

        // Free up any Stage3D textures that will no longer be needed
        for (texture in _textures) {
            texture.nativeTexture = null;
        }
        _textures = null;

        _drawCtx = null;
        _context3D = null;
        _stage3D = null;

        if (event != null) {
            Log.warn("Unexpected Stage3D error", ["error", event.text]);
        }
        Log.warn("Falling back to BitmapRenderer");

        // Fall back to software renderering
        FlashPlatform.instance.renderer = new BitmapRenderer();
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
    private var _stage3D :Stage3D;

    private var _events :EventGroup;

    private var _textures :Array<FlashTexture>;
}
