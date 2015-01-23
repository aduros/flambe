package flambe.animation;

import flambe.animation.AnimatedFloat;
import flambe.animation.Behavior;
import flambe.math.FMath;

/**
 * Controls an AnimatedFloat using a Sine wave, typically endlessly.
 * Useful for flashing a notification, or creating a throbbing animation effect without using a Script.
 * 
 * @author Kipp Ashford
 */
class Sine
    implements Behavior
{
	/** The end value. */
	public var end(default, null):Float;
	/** The starting value. */
	public var start(default, null):Float;
	/** The number of times to animate between the starting value and the end value. */
	public var cycles(default, null):Float;
	/** The speed, in seconds, it takes to animate between the starting value and the ending value (or the other way around) */
	public var speed(default, null):AnimatedFloat;
	
	/**
	 * @param start The starting value for the animated float.
	 * @param end The last value for the animated float.
	 * @param speed The speed (in seconds) it takes to go from the start value to the end value.
	 * @param cycles The number of animation cycles to go through. A value of 0 will cycle forever,
	 *   whereas a value of 1 will go from the start position, to the end position, and back to start.
	 * @param offset The number of seconds to offset the animation. Useful for offseting the animation for a series of sine behaviors.
	 */
	public function new(start:Float, end:Float, ?speed:Float = 1, ?cycles:Float = 0, ?offset:Float = 0) 
	{
		this.start = start;
		this.end = end;
		this.cycles = cycles;
		this.speed = new AnimatedFloat(speed);
		
		_count = HALF_PI + offset * (FMath.PI / speed); // Start at the start value plus the seconds to offset.
		_distance = (start - end) * .5;
		_center = end + _distance;
	}
	
	public function update(dt :Float):Float {
		this.speed.update(dt);
		_count += dt * (FMath.PI / speed._);
		if (isComplete()) {
			return _center + FMath.PI * _distance;
		}
		return _center + Math.sin(_count) * _distance;
	}
	
	public function isComplete() :Bool {
		return cycles > 0 && ((_count - HALF_PI) / FMath.PI) * .5 >= cycles;
	}
	
	/** Stores the half value of PI for quicker calculations. */
	private static inline var HALF_PI:Float = { .5 * FMath.PI; };
	/** The number of times to animate. */
	private var _count :Float;
	/** The total distance between the start and end values */
    private var _distance :Float;
	/** The middle of the start and end position, stored for quicker math. */
	private var _center :Float;
}
