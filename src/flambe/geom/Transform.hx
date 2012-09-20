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

import flash.display.MovieClip;

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
		target.scaleX = sx;
		target.scaleY = sy;
		target.rotation = angle / Math.PI * 180;
		target.x = value.tx;
		target.y = value.ty;
		return value;
	}

	public function getConcatenatedMatrix() : Matrix {
		return null;
	}

	public function new(mc : MovieClip) {
		_init(mc);
	}

	var target : MovieClip;
	var _Mt : Matrix;
	function _init(mc:MovieClip) : Void {
		//Reflect.field(mc, Std.string("transform2")) = this;
		
		//mc["transform2"] = this;
		
		Reflect.setProperty(mc, "transform2", this);
		
		
		trace(Reflect.getProperty(mc, "transform2"));
		
		
		this.target = mc;
		_Mt = new Matrix();
		_Mt.createBox(mc._xscale, mc._yscale, mc._rotation * Math.PI, mc._x, mc._y);
	}

}

