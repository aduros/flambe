/*

 * Copyright (c) 2008 michiyasu wada

 * http://www.seyself.com/

 *

 * Distributed under The MIT License.

 * [http://www.opensource.org/licenses/mit-license.php]

 */
//****************************************************************************
// ActionScript Standard Library
// flash.geom.Transform object
//****************************************************************************
package flambe.geom;

import flambe.display.Sprite;

class Transform {
	public var matrix(getMatrix, setMatrix) : Matrix;
	public var concatenatedMatrix(getConcatenatedMatrix, never) : Matrix;

	public function getMatrix() : Matrix {
		return _Mt;
	}

	public function setMatrix(value : Matrix) : Matrix {
		_Mt = value;
		var ts : Float = value.a * value.d - value.b * value.c;
		var sx : Float = Math.sqrt(value.a * value.a + value.c * value.c);
		var sy : Float = ts / sx;
		var angle : Float = Math.acos(value.a / sx);
		target.scaleX._ = sx;
		target.scaleY._ = sy;
		target.rotation._ = angle / Math.PI * 180;
		target.x._ = value.tx;
		target.y._ = value.ty;
		return value;
	}

	public function getConcatenatedMatrix() : Matrix {
		return null;
	}

	public function new(mc : Sprite) {
		_init(mc);
	}

	var target : Sprite;
	var _Mt : Matrix;
	function _init(mc:Sprite) : Void {
		//Reflect.field(mc, Std.string("transform2")) = this;
		
		//mc["transform2"] = this;
		
	//	Reflect.setProperty(mc, "transform", this);
		mc.transform=this;
		

		
		
		this.target = mc;
		_Mt = new Matrix();
		_Mt.createBox(mc._xscale, mc._yscale, mc._rotation * Math.PI, mc._x, mc._y);
	}

}

/** example
* package ;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;



import geom.Matrix;
import geom.Transform;
import flash.display.Sprite;
class Main extends Sprite
{

    public function new() {
        super();

        var myMatrix:Matrix = new Matrix();
        myMatrix.a = 1;
        myMatrix.d = 1;
        myMatrix.tx = 100;
        myMatrix.ty = 200;

//myMatrix.invert();
        var rectangleShape:Sprite = createRectangle(100, 100, 0xff0000);

        myMatrix.scale(0.5,2);
        myMatrix.rotate(45);
        var rectangleTrans:Transform = new Transform(rectangleShape);

//rectangleShape.transform2.matrix=myMatrix;

        var tr:Transform =	Reflect.getProperty(rectangleShape, "transform2");
        tr.matrix = myMatrix;

    }
    static function main()
    {
        var stage = Lib.current.stage;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;


        stage.addChild(new Main());


    }

    public function createRectangle(w:Float, h:Float, color:UInt):Sprite {
        var rect:Sprite = new Sprite();
        rect.graphics.beginFill(color);
        rect.graphics.drawRect(0, 0, w, h);
        addChild(rect);
        return rect;
    }

}
*
**/
