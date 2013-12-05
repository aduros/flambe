package flambe.display;

import flambe.display.Texture;
import flambe.math.Point;
import flambe.math.Rectangle;
import flambe.math.Size;

/**
 * ...
 * @author Ang Li(李昂)
 */
class SpriteFrame
{

	var _offset : Point;
	var _originalSize : Size;
	var _rectInPixels : Rectangle;
	var _rotated : Bool;
	var _rect : Rectangle;
	var _offsetInPixels : Point;
	var _originalSizeInPixels : Size;
	var _texture : Texture;
	var _textureFilname : String;
	
	public function new() {
		this._offset = new Point(0, 0);
		this._offsetInPixels = new Point(0, 0);
		this._originalSize = new Size(0, 0);
		this._rectInPixels = new Rectangle(0, 0, 0, 0);
		this._rect = new Rectangle(0, 0, 0, 0);
		this._originalSizeInPixels = new Size(0, 0);
		this._textureFilname = "";
}
	
	public function getRectInPixels() : Rectangle {
			return this._rectInPixels;
	}
	
	public function setRectInPixels(rectInPixels : Rectangle) {
			this._rectInPixels = rectInPixels;
			this._rect = rectInPixels;
	}
	
	public function isRotated() : Bool {
			return this._rotated;
	}
	
	public function setRotated(bRotated : Bool) {
			this._rotated = bRotated;
	}
	
	public function getRect() : Rectangle {
			return this._rect;
	}
	
	public function setRect(rect :Rectangle) {
			this._rect = rect;
			this._rectInPixels = rect;
	}
	
	public function getOffsetInPixels() : Point {
			return new Point(this._offsetInPixels.x, this._offsetInPixels.y);
	}
	
	public function setOffsetInPixels(offsetInPixels : Point) {
			this._offsetInPixels = offsetInPixels;
			this._offset = offsetInPixels;
	}
	
	public function getOriginalSizeInPixels() : Size {
			return this._originalSizeInPixels;
	}
	
	public function setOriginalSizePixels(sizeInPixels : Size) {
			this._originalSizeInPixels = sizeInPixels;
	}
	
	public function getOriginalSize() : Size {
			return new Size(this._originalSize.width, this._originalSize.height);
	}
	
	public function setOriginalSize(sizeInPixels : Size) {
			this._originalSize = sizeInPixels;
	}
	
	public function getTexture() : Texture {
			if (this._texture != null) {
					return this._texture;
			}
			return null;
	}
	
	public function setTexture(texture : Texture) {
			if (this._texture != texture) {
					this._texture = texture;
			}
	}
	
	public function getOffset() : Point {
			return new Point(this._offset.x, this._offset.y);
	}
	
	public function setOffset(offsets : Point) {
			this._offset = offsets;
	}
	
	public function initWithTexture(texture : Texture, rect : Rectangle, rotated : Bool, offset : Point, originalSize : Size) : Bool{
			this._texture = texture;
			this._rectInPixels = rect;
			this._rect = rect;
			this._offsetInPixels = offset;
			this._offset = offset;
			this._originalSizeInPixels = originalSize;
			this._originalSize = originalSize;
			this._rotated = rotated;
			return true;
	}
	
	public function toString() : String {
			var ret : String = _offset.x + "," + _offset.y + "," + isRotated() + "," + _rect.x + "," + _rect.y + "," +  _rect.width + "," + _rect.height;
			return ret;
	}
	
	public static function createWithTexture(texture : Texture, rect : Rectangle, ?rotated : Bool, ?offset : Point, ?originalSize : Size) : SpriteFrame {
			var spriteFrame : SpriteFrame = new SpriteFrame();
			spriteFrame.initWithTexture(texture, rect, rotated, offset, originalSize);
			return spriteFrame;
	}
	
}