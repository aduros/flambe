package flambe.math;

/**
 * ...
 * @author Ang Li(李昂)
 */
class Size
{

	public var width : Float;
	public var height : Float;
	public function new(?width : Float = 0, ?height : Float = 0) 
	{
			this.width = width;
			this.height = height;
	}
	
	public function setSize(width : Float , height : Float) {
			this.width = width;
			this.height = height;
	}
	
	public function equals(size : Size) : Bool {
			if (this.width == size.width && this.height == size.height) {
					return true;
			} else {
					return false;
			}
	}
	
	public function toString() : String {
			return '$width x $height';
	}
	
}