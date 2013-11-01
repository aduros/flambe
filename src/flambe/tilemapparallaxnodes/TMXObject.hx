package flambe.tilemapparallaxnodes;

/**
 * ...
 * @author Ang Li
 */
class TMXObject
{
	public var name : String;
	public var x : Float;
	public var y : Float;
	public var width : Float;
	public var height : Float;
	public var type : String;
	
	public var properties : Map<String, String>;
	public function new(?name : String, ?x : Float, ?y : Float, ?type : String, ?width : Float, ?height : Float) 
	{
		this.name = name;
		this.x = x;
		this.y = y;
		this.height = height;
		this.width = width;
		this.type = type;
		properties = new Map<String, String>();
	}
	
}