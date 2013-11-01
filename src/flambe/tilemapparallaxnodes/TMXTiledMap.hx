package flambe.tilemapparallaxnodes;
import flambe.asset.AssetPack;
import flambe.Component;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.util.Assert;
import com.tilemapparallaxnodes.TMXXMLParser;


/**
 * ...
 * @author Ang Li
 */
class TMXTiledMap extends Component
{
	/**
	 Orthogonal orientation
	 * @constant
	 * @type Number
	 */
	public static var TMX_ORIENTATION_ORTHO : Int = 0;

	/**
	 * Hexagonal orientation
	 * @constant
	 * @type Number
	 */

	public static var TMX_ORIENTATION_HEX : Int = 1;

	/**
	 * Isometric orientation
	 * @constant
	 * @type Number
	 */
	public static var TMX_ORIENTATION_ISO : Int = 2;
	
	
	//var _tiledMap : TiledMap;
	
	var _mapSize : TMXSize;
	var _tileSize : TMXSize;
	var _properties : Array < Map < String, String >> ;
	var _objectGroups : Array<TMXObjectGroup>;
	var _mapOrientation : Int;
	var _TMXLayers : Array<TMXLayer>;
	var _tileProperties : Map < Int, Map < String, String >> ;
	
	var _root : Entity;
	var pack : AssetPack;

	public function new(pack : AssetPack, tmxFile : String, ?resourcePath : String) 
	{
		_mapOrientation = 0;
		_mapSize = new TMXSize();
		_tileSize = new TMXSize();
		_objectGroups = new Array<TMXObjectGroup>();
		_TMXLayers = new Array<TMXLayer>();
		_root = new Entity();
		this.pack = pack;
		initWithTMXFile(tmxFile, resourcePath);
	}
	
	public function getMapSize() : TMXSize {
		return this._mapSize;
	}
	
	public function setMapSize(v : TMXSize) {
		this._mapSize = v;
		//this._tiledMap.height = v.height;
		//this._tiledMap.width = v.width;
	}
	
	public function getTileSize() : TMXSize {
		return this._tileSize;
	}
	
	public function setTileSize(v : TMXSize) {
		this._tileSize = v;
		//_tiledMap.tileheight = v.height;
		//_tiledMap.tilewidth = v.width;
	}
	
	public function getMapOrientation() : Int {
		return this._mapOrientation;
	}
	
	public function setMapOrientation(v : Int) {
		this._mapOrientation = v;
		//this._tiledMap.orientation
	}
	
	public function getObjectGroups() : Array<TMXObjectGroup> {
		return this._objectGroups;
	}
	
	public function setObjectGroups(v : Array<TMXObjectGroup>) {
		this._objectGroups = v;
	}
	
	//public function getProperties(
	
	public function initWithTMXFile(tmxFile : String, ?resourcePath : String) : Bool {
		Assert.that(tmxFile != null && tmxFile.length > 0, "TMXTiledMap: tmx file should not be nil");
		//this.setContentSize(new TMXSize(0, 0));
		var mapInfo = TMXMapInfo.create(pack, tmxFile, resourcePath);
		if (mapInfo == null) {
			return false;
		}
		
		Assert.that(mapInfo.getTilesets().length != 0, "TMXTiledMap: Map not found. Please check the filename.");
		this._buildWithMapInfo(mapInfo);
		return true;
	}
	
	private function _buildWithMapInfo(mapInfo : TMXMapInfo) {
		this._mapSize = mapInfo.getMapSize();
		this._tileSize = mapInfo.getTileSize();
		this._mapOrientation = mapInfo.getOrientation();
        this._objectGroups = mapInfo.getObjectGroups();
        this._properties = mapInfo.getProperties();
        this._tileProperties = mapInfo.getTileProperties();
		
		var idx = 0;
		var layers = mapInfo.getLayers();
		if (layers != null) {
			for (l in layers) {
				var entity : Entity = new Entity();
				var layer : TMXLayer = new TMXLayer(l, mapInfo);
				_root.addChild(entity.add(layer), true, idx);
				idx++;
				
				
				//var childSize : TMXSize = l._layerSize;
				//var currentSize : TMXSize = this._mapSize;
				//currentSize.width = Math.max(currentSize.width, childSize.width);
				//currentSize.height = Math.max(currentSize.height, childSize.height);
				//
				//this.setContentSize(currentSize);
				
			}
		}
	}
	
	/** return the TMXLayer for the specific layer
     * @param {String} layerName
     * @return {TMXLayer}
     */
	 public function getLayer(layerName : String) : TMXLayer {
        Assert.that(layerName != null && layerName.length > 0, "Invalid layer name!");
		
		var firstChild : Entity = owner.firstChild;
		while (firstChild != null) {
			var layer : TMXLayer = firstChild.get(TMXLayer);
			if (layer != null) {
				if (layer.getLayerName() == layerName) {
					return layer;
				}
			} 
			
			firstChild = firstChild.next;
		}
        //for (i in 0...owner.firstChild) {
            //var layer : TMXLayer = cast (this._children[i], TMXLayer);
            //if (layer != null) {
                //if (layer.getLayerName() == layerName) {
                    //return layer;
                //}
            //}
        //}

        // layer not found
        return null;
    }
	
	public function getObjectGroup(groupName : String) : TMXObjectGroup {
		Assert.that(groupName != null && groupName.length > 0, "Invalid group name!");
		if (this._objectGroups != null) {
			for (o in _objectGroups) {
				if (o != null && o.getGroupName() == groupName) {
					return o;
				}
			}
		}
		return null;
	}
	
	override public function onAdded()
	{
		owner.addChild(_root);
	}
	
	override public function onRemoved()
	{
		_root.dispose();
	}
}