package flambe.tilemapparallaxnodes;
import flambe.math.Point;

/**
 * ...
 * @author Ang Li
 */
class TMXObjectGroup
{
	var _groupName : String = "";
	var _positionOffset : Point;
	var _properties : Map<String, String>;
	var _objects : Array<TMXObject>;
	public function new() 
	{
		_properties = new Map<String, String>();
		_objects = new Array<TMXObject>();
	}
	
	public function getPositionOffset() : Point {
		return this._positionOffset;
	}
	
	public function setPositionOffset(v : Point) {
		this._positionOffset = v;
	}
	
	public function getProperties() : Map < String, String > {
		return this._properties;
	}
	
	public function setProperties(name : String, value : String) {
		this._properties.set(name, value);
	}
	
	public function getGroupName() : String {
		return this._groupName;
	}
	
	public function setGroupName(s : String) {
		this._groupName = s;
	}
	
	public function propertyNamed(propertyName) : String {
		return this._properties[propertyName];
	}
	
	public function objectNamed(objectName : String) : TMXObject {
		if (this._objects != null && this._objects.length > 0) {
			for (o in this._objects) {
				if (o.name == objectName) {
					return o;
				}
			}
		}
		return null;
	}
	
	public function getObjects() : Array<TMXObject> {
		return this._objects;
	}
	
	public function setObjects(object : TMXObject) {
		this._objects.push(object);
	}
}