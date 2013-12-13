package flambe.tilemap;
import flambe.display.SpriteFrame;
import flambe.asset.AssetPack;
import flambe.Component;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.tilemap.TMXXMLParser;
import flambe.math.Point;
import flambe.math.Rectangle;
import flambe.math.Size;
import flambe.util.Assert;

/**
 * 
 * @author Ang Li(李昂)
 */
class TMXTiledMap
{
	public static var useViewport : Bool = false;
	public static var viewport : Rectangle = new Rectangle();
	
	public static var TMX_ORIENTATION_ORTHO : Int = 0;

	public static var TMX_ORIENTATION_HEX : Int = 1;
	
	public static var TMX_ORIENTATION_ISO : Int = 2;
	
	
	//var _tiledMap : TiledMap;
	
	var _mapSize : Size;
	var _tileSize : Size;
	var _properties : Array < Map < String, String >> ;
	var _objectGroups : Array<TMXObjectGroup>;
	var _mapOrientation : Int;
	var _TMXLayers : Array<TMXLayer>;
	var _tileProperties : Map < Int, Map < String, String >> ;
	
	var _root : Entity;
	var _pack : AssetPack;
	var _sprite : Sprite;
	public function new(pack : AssetPack, tmxFile : String, ?resourcePath : String) 
	{
		_mapOrientation = 0;
		_mapSize = new Size();
		_tileSize = new Size();
		_objectGroups = new Array<TMXObjectGroup>();
		_TMXLayers = new Array<TMXLayer>();
		_pack = pack;
		_root = new Entity();
		initWithTMXFile(tmxFile, resourcePath);
		_sprite = new Sprite();
	}
	
	public function getMapSize() : Size {
		return this._mapSize;
	}
	
	public function setMapSize(v : Size) {
		this._mapSize = v;
	}
	
	public function getTileSize() : Size {
		return this._tileSize;
	}
	
	public function setTileSize(v : Size) {
		this._tileSize = v;
	}
	
	public function getMapOrientation() : Int {
		return this._mapOrientation;
	}
	
	public function setMapOrientation(v : Int) {
		this._mapOrientation = v;
	}
	
	public function getObjectGroups() : Array<TMXObjectGroup> {
		return this._objectGroups;
	}
	
	public function setObjectGroups(v : Array<TMXObjectGroup>) {
		this._objectGroups = v;
	}
	
	/**
	 * Return properties dictionary for tile GID
	 * @param	GID
	 * @return
	 */
	 public function propertiesForGID(GID : Int) : Map<String, String> {
        return this._tileProperties[GID];
    }
	
	public function initWithTMXFile(tmxFile : String, ?resourcePath : String) : Bool {
		Assert.that(tmxFile != null && tmxFile.length > 0, "TMXTiledMap: tmx file should not be nil");
		var mapInfo : TMXMapInfo = TMXMapInfo.create(this._pack, tmxFile, resourcePath);
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
		
		var layers = mapInfo.getLayers();
		if (layers != null) {
			for (l in layers) {
				var child : TMXLayer = this._parseLayer(l, mapInfo);
				_root.addChild(child.getRoot(), true, l.idx);
				this._TMXLayers.push(child);
			}
		}

		var objects = mapInfo.getObjectGroups();
		for (obj in objects) {
			if (obj.isRender) {
				for (o in obj.getObjects()) {
					if (o.gid != -1) {
						var tilesets : Array<TMXTilesetInfo> = mapInfo.getTilesets();
						for (tileset in tilesets) {
							if ((o.gid >= tileset.firstGid && o.gid <= tileset.lastGid) 
							|| (o.gid >= tileset.firstGid && tileset.lastGid == 0)) {
								if (this._mapOrientation == TMX_ORIENTATION_ISO) {
									var rect : Rectangle = tileset.rectForGID(o.gid);
									var sprite : TMXSprite = new TMXSprite(rect, tileset.texture);
									sprite.setAnchor(sprite.getNaturalWidth() / 2, sprite.getNaturalHeight());
									
									var x = o.x;
									var y = o.y;
									
									var tileWidth = this.getTileSize().width;
									var tileHeight = this.getTileSize().height;
									var edge = tileHeight;
									
									var yt : Float=  y / edge; 
									var xt : Float = x / edge;
									var retx = tileWidth / 2 
									* ( this.getMapSize().height + xt - yt);
									var rety = tileHeight / 2 
									* (xt + yt);
									
									o.realX = retx;
									o.realY = rety;
									o.width = rect.width;
									o.height = rect.height;
									sprite.setXY(retx, rety);
									_root.addChild(new Entity().add(sprite), true, obj.idx);
								}
							}
						}
					}
				}
			}
		}
	}
	
	private function _parseLayer(layerInfo, mapInfo) : TMXLayer {
		var layer : TMXLayer = TMXLayer.create(layerInfo, mapInfo);
		layer.setupTiles();
		return layer;
	}
	
	private function _tilesetForLayer(layerInfo : TMXLayerInfo, mapInfo : TMXMapInfo) : TMXTilesetInfo {
		var size = layerInfo._layerSize;
        var tilesets = mapInfo.getTilesets();
        if (tilesets != null) {
			var i = tilesets.length - 1;
			while ( i >= 0) {
                var tileset = tilesets[i];
                if (tileset != null) {
                    for (y in 0...Std.int(size.height)) {
                        for (x in 0...Std.int(size.width)) {
                            var gid = layerInfo._tiles[Std.int(y * size.width) + x];
                            if (gid != 0) {
                                if (((gid & TMXXMLParser.TMX_TILE_FLIPPED_MASK)>>>0) >= tileset.firstGid) {
                                    return tileset;
                                }
                            }

                        }
                    }
                }
				i--;
            }
		}
		return null;
	}
	
	/**
	 * return the TMXLayer for the specific layer
	 * @param	layerName
	 * @return
	 */
	
	 public function getLayer(layerName : String) : TMXLayer {
        Assert.that(layerName != null && layerName.length > 0, "Invalid layer name!");
		
		for (l in _TMXLayers) {
			if (l.getLayerName() == layerName) {
				return l;
			}
		}
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
	
	public function getRoot() : Entity {
		return this._root;
	}
	
	public function clear() {
		this._root.dispose();
		for (l in this._TMXLayers) {
			l.getRoot().dispose();
			l.clear();
		}
	}
}