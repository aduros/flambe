package flambe.tilemapparallaxnodes;


import flambe.display.Graphics;
import flambe.display.Sprite;
import flambe.math.Point;
import flambe.math.Rectangle;
import haxe.Int64;
import com.tilemapparallaxnodes.TMXXMLParser;
import flambe.util.Assert;
/**
 * ...
 * @author Ang Li
 */
class TMXLayer extends Sprite
{
	var _layerSize : TMXSize;
	var _mapTileSize : TMXSize;
	var _tiles : Array<Array<Int>>;
	//var _tileSet : TMXTilesetInfo;
	var _layerOrientation : Int;
	var _properties : Map<String, String>;
	var _layerName : String;
	//var _opacity : Int;
	var _minGID : Int;
	var _maxGID : Int;
	
	var _layerInfo : TMXLayerInfo;
	var _mapInfo : TMXMapInfo;
	
	
	public function new(layerInfo : TMXLayerInfo, mapInfo : TMXMapInfo) 
	{
		super();
		this._layerSize = new TMXSize();
		this._mapTileSize = new TMXSize();
		//this._opacity = 255;
		this.alpha._ = 1;
		this._layerName = "";
		_tiles = new Array<Array<Int>>();
		_properties = new Map<String, String>();
		initWithTilesetInfo(layerInfo, mapInfo);
	}
	
	public function getLayerSize() : TMXSize {
		return this._layerSize;
	}
	
	public function setLayerSize(v : TMXSize) {
		this._layerSize = v;
	}
	
	public function getLayerName() : String {
		return this._layerName;
	}
	
	public function setLayerName(layerName : String) {
		this._layerName = layerName;
	}
	
	public function getMapTileSize() : TMXSize {
		return this._mapTileSize;
	}
	
	public function setMapTileSize(v : TMXSize) {
		this._mapTileSize = v;
	}
	
	public function getTiles() : Array<Array<Int>> {
		return this._tiles;
	}
	
	public function setTiles(v : Array<Array<Int>>) {
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
        var tile = this._tiles[Std.int(pos.y)][Std.int(pos.x)];
		return tile;
	}
	
	public function initWithTilesetInfo(layerInfo : TMXLayerInfo, mapInfo : TMXMapInfo) : Bool {
		var size = layerInfo._layerSize;
		var totalNumberOfTiles = Std.int(size.width * size.height);
		
		this._layerSize = layerInfo._layerSize;
		this._layerName = layerInfo.name;
		this._tiles = layerInfo._tiles;
		this._minGID = layerInfo._minGID;
		this._maxGID = layerInfo._maxGID;
		this.setProperties(layerInfo.getProperties());
		this.alpha._ = layerInfo._opacity / 255;
		//this.setOpacity(this._opacity);
		
		this._layerInfo = layerInfo;
		this._mapInfo = mapInfo;
		
		
		return true;
	}
	
	override public function draw(g:Graphics)
	{
		var count : Int = 0;

		for (row in 0..._layerInfo._tiles.length) {
			for (col in 0..._layerInfo._tiles[0].length) {
				var gid = _layerInfo._tiles[row][col];
				if (gid == 0) {
					continue;
				} else {
					var tilesetInfo : TMXTilesetInfo = getTilesetInfo(gid);
					var o : Int = _mapInfo.getOrientation();
					var x : Float = 0;
					var y : Float = 0;
					if (o == TMXTiledMap.TMX_ORIENTATION_ORTHO) {
						x = col * _mapInfo.getTileSize().width;
						y = row * _mapInfo.getTileSize().height;
						//trace("ortho");
					} else if (o == TMXTiledMap.TMX_ORIENTATION_ISO) {
						x = _mapInfo.getTileSize().width / 2 
							* ( this._layerInfo._layerSize.width + col - row);
						y = _mapInfo.getTileSize().height / 2 
							* (row + col) - tilesetInfo._tileSize.height;
					}
					
					var rect : Rectangle = tilesetInfo.rectForGID(gid);
					
					g.drawSubImage(tilesetInfo.texture, x, y, rect.x, rect.y, rect.width, rect.height);
				}
			}
		}
	}
	
	private function getTilesetInfo(gid : Int) : TMXTilesetInfo {
		//trace(gid);
		var a = _mapInfo.getTilesets();
		//var tileset : TMXTilesetInfo = new TMXTilesetInfo();
		for (i in 0..._mapInfo.getTilesets().length) {
			//trace(a[i].firstGid);
			if (a[i + 1] != null) {
				if (gid >= a[i].firstGid && gid < a[i + 1].firstGid) {
					//trace(gid);
					return a[i];
				}
			} else {
				return a[i];
			}
		}
		return null;
	}
	
	override public function getNaturalWidth():Float 
	{
		return _layerInfo._layerSize.width * _mapInfo.getTileSize().width;
	}
	
	override public function getNaturalHeight():Float 
	{
		return _layerInfo._layerSize.height * _mapInfo.getTileSize().height;
	}
	
}