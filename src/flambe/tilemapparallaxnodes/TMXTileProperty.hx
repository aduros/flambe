package flambe.tilemapparallaxnodes;

/**
 * ...
 * @author Ang Li
 */
class TMXTileProperty
{
	public var name : String;
	public var value : String;
	public function new(?name :String="", ?value : String = "") 
	{
		this.name = name;
		this.value = value;
	}
	
}