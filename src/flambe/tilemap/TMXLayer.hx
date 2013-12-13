package flambe.tilemap;

import flambe.Component;
import flambe.Entity;
import flambe.math.Point;
import dev.math.Rectangle;
import flambe.util.Assert;
import haxe.Int64;
import dev.tilemap.TMXXMLParser;
import dev.math.Size;

/**
 * 
 * @author Ang Li(李昂)
 */
class TMXLayer 
{
	var _layerSize : Size;
	var _mapTileSize : Size;
	var _tiles : Array<Int>;
	var _tileSet : TMXTilesetInfo;
	var _layerOrientation : Int;
	var _properties : Map<String, String>;
	var _layerName : String;
	var _opacity : Int;
	var _minGID : Int;
	var _maxGID : Int;
	var _useAutomaticVertexZ : Bool;
	var _vertexZvalue : Int;
	
	var _root : Entity;
	var _sprites : Array<TMXSprite>;
	public function new() 
	{
		this._layerSize = new Size();
		this._mapTileSize = new Size();
		this._opacity = 255;
		this._layerName = "";
		_tiles = new Array<Int>();
		_properties = new Map<String, String>();
		_useAutomaticVertexZ = false;
		
		_root = new Entity();
		_sprites = new Array<TMXSprite>();
	}
	
	public function getVertexZvalue() : Int {
		return this._vertexZvalue;
	}
	
	public function isAutomaticVertexZ() : Bool {
		return _useAutomaticVertexZ;
	}
	
	public function getLayerSize() : Size {
		return this._layerSize;
	}
	
	public function setLayerSize(v : Size) {
		this._layerSize = v;
	}
	
	public function getLayerName() : String {
		return this._layerName;
	}
	
	public function setLayerName(layerName : String) {
		this._layerName = layerName;
	}
	
	public function getMapTileSize() : Size {
		return this._mapTileSize;
	}
	
	public function setMapTileSize(v : Size) {
		this._mapTileSize = v;
	}
	
	public function getTiles() : Array<Int> {
		return this._tiles;
	}
	
	public function setTiles(v : Array<Int>) {
		this._tiles = v;
	}
	
	//public function getTileSet() : TMXTilesetInfo {
		//return this._tileSet;
	//}
	//
	//public function setTileSet(v : TMXTilesetInfo) {
		//this._tileSet = v;
	//}
	
	public function getLayerOrientation() : Int {
		return this._layerOrientation;
	}
	
	public function setLayerOrientation(v : Int) {
		this._layerOrientation = v;
	}
	
	public function getProperties() : Map < String, String > {
		return this._properties;
	}
	
	public function setProperties(v : Map < String, String > ) {
		this._properties = v;
	}
	
	public function getTileGIDAt(pos : Point) : Int {
		Assert.that(pos.x < this._layerSize.width && pos.y < this._layerSize.height && pos.x >= 0 && pos.y >= 0, "TMXLayer: invalid position");
        var tile = this._tiles[Std.int(pos.y * this._layerSize.width) + Std.int(pos.x)];
		return tile;
	}
	
	var _mapInfo : TMXMapInfo = null;
	var _layerInfo : TMXLayerInfo = null;
	public function initWithTilesetInfo(layerInfo : TMXLayerInfo, mapInfo : TMXMapInfo) : Bool {
		var size = layerInfo._layerSize;
		_mapInfo = mapInfo;
		this._layerInfo = layerInfo;

		this._layerSize = layerInfo._layerSize;
		this._layerName = layerInfo.name;
		this._tiles = layerInfo._tiles;
		this._minGID = layerInfo._minGID;
		this._maxGID = layerInfo._maxGID;
		this.setProperties(layerInfo.getProperties());
		this._opacity = layerInfo._opacity;
		this._parseInternalProperties();
		
		this._mapTileSize = mapInfo.getTileSize();
		this._layerOrientation = mapInfo.getOrientation();
		
		this._vertexZvalue = 0;
		return true;
	}
	
	public function setupTiles()
	{
		var count : Int = 0;
		for (row in 0...Std.int(_layerInfo._layerSize.height)) {
			for (col in 0...Std.int(_layerInfo._layerSize.width)) {
				var gid = _layerInfo._tiles[Std.int(col + row * _layerInfo._layerSize.width)];
				if (gid == 0) {
					continue;
				} else {
					var tilesetInfo : TMXTilesetInfo = getTilesetInfo(gid);
					var o : Int = this._layerOrientation;
					var x : Float = 0;
					var y : Float = 0;
					if (o == TMXTiledMap.TMX_ORIENTATION_ORTHO) {
						x = col * this._mapTileSize.width;
						y = row * _mapTileSize.height;
					} else if (o == TMXTiledMap.TMX_ORIENTATION_ISO) {
						x = this._mapTileSize.width / 2 
							* ( this._layerSize.height + col - row - 1) ;
						y = this._mapTileSize.height / 2 
							* (row + col + 2) - tilesetInfo._tileSize.height;
					}
						
					var rect : Rectangle = tilesetInfo.rectForGID(gid);
					var sprite : TMXSprite = new TMXSprite(rect, tilesetInfo.texture, TMXTiledMap.useViewport);
					sprite.setXY(x, y);
					sprite.alpha._ = this._opacity / 255;
					_root.addChild(new Entity().add(sprite), true, _vertexZForPos(row, col));
					_sprites.push(sprite);
				}
			}
		}
	}
	
	private function getTilesetInfo(gid : Int) : TMXTilesetInfo {
		var a = _mapInfo.getTilesets();
		for (i in 0..._mapInfo.getTilesets().length) {
			if (a[i + 1] != null) {
				if (gid >= a[i].firstGid && gid < a[i + 1].firstGid) {
					return a[i];
				}
			} else {
				return a[i];
			}
		}
		return null;
	}
	
	private function _vertexZForPos(row : Int, col : Int) : Int {
		var ret : Int = 0;
		var maxVal = 0;
		if (this._useAutomaticVertexZ) {
			switch(this._layerOrientation) {
				case TMXTiledMap.TMX_ORIENTATION_ISO :
					ret = row + col;
				case TMXTiledMap.TMX_ORIENTATION_ORTHO :
					ret = row;
				default :
					null;
			}
		} else {
			ret = this._vertexZvalue;
		}
		
		return ret;
	}
	
	public static function create(layerInfo : TMXLayerInfo, mapInfo : TMXMapInfo) {
		var ret = new TMXLayer();
		if (ret.initWithTilesetInfo(layerInfo, mapInfo)) {
			return ret;
		}
		
		return null;
	}
	
	/**
	 * Return the value for the specific property name
	 * @param	propertyName
	 * @return
	 */
	public function getProperty(propertyName : String) : String {
        return this._properties[propertyName];
    }
	
    private function _parseInternalProperties() {
        // if vertex=automatic, then tiles will be rendered using vertexz
        var vertexz : String = this.getProperty("vertexz");
        if (vertexz != null) {
            if (vertexz == "automatic") {
                this._useAutomaticVertexZ = true;
            } else
                this._vertexZvalue = Std.parseInt(vertexz);
        }
    }
	
	public function getRoot() : Entity {
		return _root;
	}
	
	public function clear() {
		for (s in _sprites) {
			s.dispose();
		}
	}
}