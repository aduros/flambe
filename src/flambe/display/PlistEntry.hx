package flambe.display;

/**
 * ...
 * @author Ang Li(李昂)
 */
class PlistEntry
{

	public var name : String;
	public var x : Float;
	public var y : Float;
	public var width : Float;
	public var height : Float;
	public var sourceColorX : Float;
	public var sourceColorY : Float;
	public var rotated : Bool;
	
	
	public function new(?entry : PlistEntry) {
		if (entry == null) {
			return;
		}
		this.name = entry.name;
		this.x = entry.x;
		this.y = entry.y;
		this.width = entry.width;
		this.height = entry.height;
		this.sourceColorX = entry.sourceColorX;
		this.sourceColorY = entry.sourceColorY;
		this.rotated = entry.rotated;
	}
	
	public function toString() : String {
		var ret : String = name + "," + Std.string(x) + "," + Std.string(y) + "," +
			Std.string(sourceColorX) + "," + Std.string(sourceColorY) + "," + Std.string(rotated);
		return ret;
		
	}	
	
}