//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.debug;

import flambe.display.Sprite;
import flambe.util.Assert;

import haxe.Timer;

/**
 * A component that tests the performance of the device
 * The higher the number, the better the device
 */
class Benchmark
{
    public static function start (fn:Float -> Void = null)
    {
        _calledStart = true;
        _calledCleanup = false;
        _fn = fn;
        _root = new Entity();
        _sprites = new Array<Sprite>();
        _timeStart = System.time;
        System.root.addChild(_root);
        Timer.delay(benchmark, 1000);
    }
	
    public static function results () :Float
    {
        if (!_calledStart) { 
            Log.warn("You must call Benchmark.start() first! Returning 0");
            return 0;
        }
        if (!_calledCleanup) { 
            Log.warn("Benchmark is still running the test! Returning 0");
            return 0;
        }
        return _benchmark;
    }
	
    private static function benchmark ()
    {
		var sprite;
        for (ii in 0...250) {
            sprite = new Sprite();
            sprite.pointerEnabled = false;
            _root.add(sprite);
            _sprites.push(sprite);
        }
		
        if (_sprites.length < 5000) {
            Timer.delay(benchmark, 100);
        }
        else {
            cleanup();
        }
    }
	
    private static function cleanup ()
    {
        var num = _sprites.length;
        for (ii in 0..._sprites.length)
        {
            _root.remove(_sprites[ii]);
        }
        System.root.removeChild(_root);
        _sprites = null;
		
        var timeDif = System.time - _timeStart;
        var bm = Math.round(1 / timeDif * 10000);
        _benchmark = bm;
        _calledCleanup = true;
        if (_fn != null) {
            Reflect.callMethod(null, _fn, [_benchmark]);
        }
    }
	
    private static var _benchmark :Float;
    private static var _calledStart = false;
    private static var _calledCleanup = false;
    private static var _fn :Float -> Void;
    private static var _root :Entity;
    private static var _sprites :Array<Sprite>;
    private static var _timeStart :Float;
}
