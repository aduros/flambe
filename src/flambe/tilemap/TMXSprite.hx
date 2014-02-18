package flambe.tilemap;
import flambe.display.Graphics;
import flambe.display.Sprite;
import flambe.tilemap.TMXXMLParser;
import flambe.math.Point;
import flambe.math.Rectangle;
import flambe.display.Texture;

/**
 * 
 * @author Ang Li(李昂)
 */
class TMXSprite extends Sprite
{
	var texture : Texture;
	var rect : Rectangle;
	var isTiledMap : Bool;
	
	public function new(rect : Rectangle, texture : Texture, ?isTiledMap : Bool = false) 
	{
		super();
		this.rect = rect;
		this.isTiledMap = isTiledMap;
		this.texture = texture;
	}
	
	override public function draw(g:Graphics)
	{
		if (isTiledMap) {
			var t : Rectangle = new Rectangle(this.x._, this.y._, rect.width, rect.height);
			if (t.intersect(TMXTiledMap.viewport)) {
				g.drawSubImage(texture, 0, 0, rect.x, rect.y, rect.width, rect.height);
			}
		} else {
			g.drawSubImage(texture, 0, 0, rect.x, rect.y, rect.width, rect.height);
		}
	}
	
	override public function getNaturalHeight():Float 
	{
		if (this.rect == null) {
			return 0;
		}
		return rect.height;
	}
	
    override public function getNaturalWidth():Float 
	{
		if (this.rect == null) {
			return 0;
		}
		return rect.width;
	}
}