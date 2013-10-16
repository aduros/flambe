//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.debug;

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
        _entities = new Array<Entity>();
        _fn = fn;
        _timeStart = System.time;
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
        for (ii in 0...250) {
            _entities.push(System.root.addChild(new Entity()));
        }
		
        if (_entities.length < 5000) {
            Timer.delay(benchmark, 100);
        }
        else {
            cleanup();
        }
	}
	
	private static function cleanup ()
	{
        var num = _entities.length;
        for (ii in 0..._entities.length)
        {
            System.root.removeChild(_entities[ii]);
        }
        _entities = null;
		
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
    private static var _entities :Array<Entity>;
    private static var _fn :Float -> Void;
    private static var _timeStart :Float;
}
