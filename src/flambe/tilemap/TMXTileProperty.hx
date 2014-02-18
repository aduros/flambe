package flambe.tilemap;

/**
 * 
 * @author Ang Li(李昂)
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