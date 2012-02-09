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
    }

    public function uploadTexture (texture :Texture)
    {
        var flashTexture = cast texture;
        _textures.push(flashTexture);
        uploadToContext3D(flashTexture);
    }

    public function willRender () :DrawingContext
    {
        if (_context3D == null) {
            return null;
        }
        _context3D.clear();
        return _drawCtx;
    }

    public function didRender ()
    {
        _context3D.present();
    }

    public function init ()
    {
        var stage = Lib.current.stage;

        stage.addEventListener(Event.RESIZE, onResize);

        // Use the first available Stage3D
        for (stage3D in stage.stage3Ds) {
            if (stage3D.context3D == null) {
                _stage3D = stage3D;
                _stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
                _stage3D.addEventListener(ErrorEvent.ERROR, onError);
                _stage3D.requestContext3D();
                return;
            }
        }

        // No Stage3Ds available!
        onError(null);
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
            var resized = new BitmapData(w2, h2, bitmapData.transparent);
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

        // if (_context3D.driverInfo.indexOf("Software") != -1) {
        //     var ref = _context3D;
        //     onError(null);
        //     ref.dispose();
        //     return;
        // }

        // Re-upload any lost textures to the GPU
        for (texture in _textures) {
            uploadToContext3D(texture);
        }

        _drawCtx = new Stage3DDrawingContext(_context3D);
        onResize(null);
    }

    private function onError (_)
    {
        // The actual Stage3D will live on, so free up these listeners
        if (_stage3D != null) {
            _stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
            _stage3D.removeEventListener(ErrorEvent.ERROR, onError);
        }
        Lib.current.stage.removeEventListener(Event.RESIZE, onResize);

        // Free up some Textures that will no longer be needed
        for (texture in _textures) {
            texture.nativeTexture = null;
        }
        _textures = null;

        _drawCtx = null;
        _context3D = null;
        _stage3D = null;

        // Fall back to software renderering
        FlashAppDriver.getInstance().renderer = new BitmapRenderer();
    }

    private function onResize (_)
    {
        if (_context3D != null) {
            var stage = Lib.current.stage;
            // TODO(bruno): Vary anti-alias quality depending on the environment
            _context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, false);
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

    private var _drawCtx :DrawingContext;
    private var _context3D :Context3D;
    private var _stage3D :Stage3D;

    private var _textures :Array<FlashTexture>;
}
