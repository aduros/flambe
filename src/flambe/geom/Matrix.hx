/*

* Copyright (c) 2008 michiyasu wada

* http://www.seyself.com/

* 

* Distributed under The MIT License.

* [http://www.opensource.org/licenses/mit-license.php]

*/
//****************************************************************************
// ActionScript Standard Library
// flash.geom.Matrix object
//****************************************************************************
package flambe.geom;

import flash.geom.Point;

class Matrix {

	public var a : Float;
	public var b : Float;
	public var c : Float;
	public var d : Float;
	public var tx : Float;
	public var ty : Float;
	var u : Float;
	var v : Float;
	var w : Float;
	public function new(a : Float = 1, b : Float = 0, c : Float = 0, d : Float = 1, tx : Float = 0, ty : Float = 0) {
		a = 1;
		b = 0;
		c = 0;
		d = 1;
		tx = 0;
		ty = 0;
		u = 0;
		v = 0;
		w = 1;
		this.a = ((Math.isNaN(a))) ? 1 : a;
		this.b = ((Math.isNaN(b))) ? 0 : b;
		this.c = ((Math.isNaN(c))) ? 0 : c;
		this.d = ((Math.isNaN(d))) ? 1 : d;
		this.tx = ((Math.isNaN(tx))) ? 0 : tx;
		this.ty = ((Math.isNaN(ty))) ? 0 : ty;
		this.u = 0;
		this.v = 0;
		this.w = 1;
	}

	public function clone() : Matrix {
		return new Matrix(a, b, c, d, tx, ty);
	}

	public function concat(m : Matrix) : Void {
		var _a : Float = a * m.a + b * m.c + tx * m.u;
		var _b : Float = a * m.b + b * m.d + tx * m.v;
		var _tx : Float = tx * m.a + ty * m.c + w * m.tx;
		var _c : Float = c * m.a + d * m.c + ty * m.u;
		var _d : Float = c * m.b + d * m.d + ty * m.v;
		var _ty : Float = tx * m.b + ty * m.d + w * m.ty;
		//var _u:Number  = u  * m.a  + v  * m.c  + w  * m.u;
		//var _v:Number  = u  * m.b  + v  * m.d  + w  * m.v;
		//var _w:Number  = u  * m.tx + v  * m.ty + w  * m.w;
		a = _a;
		b = _b;
		tx = _tx;
		c = _c;
		d = _d;
		ty = _ty;
	}

	public function invert() : Void {
		var det : Float = a * (d * w - ty * v) + c * (v * tx - w * b) + u * (b * ty - tx * d);
		if(det == 0) 
			det = 1;
		var x : Float = tx;
		var y : Float = ty;
		var _a = (d * w - y * v) / det;
		var _b = (x * v - b * w) / det;
		var _tx = (y * b - x * d) / det;
		var _c = (y * u - c * w) / det;
		var _d = (a * w - x * u) / det;
		var _ty = (x * c - y * a) / det;
		//var _u  = ( c * v - d * u ) / det;
		//var _v  = ( b * u - a * v ) / det;
		//var _w  = ( a * d - b * c ) / det;
		a = _a;
		b = _b;
		//   tx = _tx;
		c = _c;
		d = _d;
		//   ty = _ty;
		//u = _u;   v = _v;   w  = _w;
		tx = -x * a + -y * c;
		ty = -x * b + -y * d;
	}

	public function identity() : Void {
		a = 1;
		b = 0;
		tx = 0;
		c = 0;
		d = 1;
		ty = 0;
		u = 0;
		v = 0;
		w = 1;
	}

	public function createBox(scaleX : Float, scaleY : Float, rotation : Float, tx : Float, ty : Float) : Void {
		identity();
		_trans(scaleX, scaleY, rotation, tx, ty);
	}

	public function createGradientBox(width : Float, height : Float, rotation : Float, tx : Float, ty : Float) : Void {
		identity();
		var t : Float = 0.0006103515625;
		var angle : Float = rotation;
		var nx : Float = t * width;
		var ny : Float = t * height;
		var x : Float = width / 2 + tx;
		var y : Float = height / 2 + ty;
		_trans(nx, ny, angle, x, y);
	}

	public function rotate(angle : Float) : Void {
		_trans(1, 1, angle, 0, 0);
	}

	public function translate(tx : Float, ty : Float) : Void {
		_trans(1, 1, 0, tx, ty);
	}

	public function scale(sx : Float, sy : Float) : Void {
		_trans(sx, sy, 0, 0, 0);
	}

	public function deltaTransformPoint(pt : Point) : Point {
		return _transPoint(pt, 0, 0);
	}

	public function transformPoint(pt : Point) : Point {
		return _transPoint(pt, tx, ty);
	}

	public function toString() : String {
		return "(a=" + a + ", b=" + b + ", c=" + c + ", d=" + d + ", tx=" + tx + ", ty=" + ty + ")";
	}

	// private methods ================================================
		function _trans(scaleX : Float, scaleY : Float, rotation : Float, _tx : Float, _ty : Float) : Void {
		var ts : Float = a * d - b * c;
		var sx : Float = Math.sqrt(a * a + c * c);
		var sy : Float = ts / sx;
		var angle : Float = Math.acos(a / sx) + rotation;
		var nx : Float = scaleX * sx;
		var ny : Float = scaleY * sy;
		var cosa : Float = Math.cos(angle);
		var sina : Float = Math.sin(angle);
		a = cosa * nx;
		b = sina * ny;
		c = -sina * nx;
		d = cosa * ny;
		tx += _tx;
		ty += _ty;
	}

	function _transPoint(pt : Point, x : Float, y : Float) : Point {
		var ts : Float = a * d - b * c;
		var sx : Float = Math.sqrt(a * a + c * c);
		var sy : Float = ts / sx;
		var angle : Float = Math.acos(a / sx);
		var dx : Float = pt.x * sx;
		var dy : Float = pt.y * sy;
		var cosa = Math.cos(angle);
		var sina = Math.sin(angle);
		var nx : Float = cosa * dx - sina * dx;
		var ny : Float = sina * dy + cosa * dy;
		return new Point(nx + x, ny + y);
	}

}

