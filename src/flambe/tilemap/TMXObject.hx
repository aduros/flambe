package flambe.tilemap;

/**
 * 
 * @author Ang Li(李昂)
 */
class TMXObject
{
	public var name : String;
	public var x : Float;
	public var y : Float;
	public var width : Float;
	public var height : Float;
	public var type : String;
	public var gid : Int;
	public var realX : Float = -1;
	public var realY : Float = -1;
	
	public var properties : Map<String, String>;
	public function new(?name : String, ?x : Float, ?y : Float, ?type : String, ?width : Float, ?height : Float, ?gid : Int = -1) 
	{
		this.name = name;
		this.x = x;
		this.y = y;
		this.height = height;
		this.width = width;
		this.type = type;
		this.gid = gid;
		properties = new Map<String, String>();
	}
	
}