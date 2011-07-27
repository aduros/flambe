//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package shooter;

import flambe.System;

class Main
{
    private static function main ()
    {
        System.init();
        var loader = System.loadAssetPack("bootstrap");
        loader.success.connect(function () {
            ShooterCtx.pack = loader.pack;
            System.root.add(new Game());
        });
        loader.error.connect(function (message) {
            trace("Loading error: " + message);
        });
        loader.progress.connect(function () {
            trace("Loading progress... " + loader.bytesLoaded + " of " + loader.bytesTotal);
        });
        loader.start();
    }
}
