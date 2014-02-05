package flambe.display;
import flambe.display.Sprite;
import flambe.display.Texture;
import flambe.display.Graphics;

/**
 * ...
 * @author Ang Li(李昂)
 */
class SpriteSheet extends Sprite
{
	public var texture : Texture;
	public var g : Graphics;

	var c : Int = 2;
	public var frame : SpriteFrame;
	
	public function new(frame : SpriteFrame) 
	{
		super();
		this.frame = frame;
	}
	
	public function updateFrame(frame : SpriteFrame) {
		this.frame = frame;
	}
	
	var flag : Bool = true;
	override public function draw(g:Graphics)
	{
		this.g = g;

		if (frame.isRotated()) {
			g.translate(frame.getOffset().x, frame.getOffset().y + frame.getRect().height);
			g.rotate( -90);
			g.drawSubImage(frame.getTexture(), 0, 0, frame.getRect().x, frame.getRect().y, 
			frame.getRect().height, frame.getRect().width);
			
		} else {
			g.translate(frame.getOffset().x, frame.getOffset().y);
			g.drawSubImage(frame.getTexture(), 0, 0, frame.getRect().x, frame.getRect().y, 
			frame.getRect().width, frame.getRect().height);
		}
	}
	
	public function getCurrentFrame() : SpriteFrame {
		return frame;
	}
	
	override public function getNaturalHeight():Float 
	{
		if (this.frame == null) {
			return 0;
		}
		return frame.getRect().height;
	}
	
    override public function getNaturalWidth():Float 
	{
		if (this.frame == null) {
			return 0;
		}
		return frame.getRect().width;
	}
	
}