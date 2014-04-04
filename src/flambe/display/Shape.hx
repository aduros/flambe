//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.display.Shape.LineCaps;
import flambe.display.Sprite;
import flambe.math.Point;
import flambe.math.FMath;
import flambe.util.Assert;

enum LineCaps
{
    None;
    Rounded;
}

/**
 * A user defined shape (line, rectangle, polygon) that is assembled by adding
 * various primitives together. Can be transformed like any Sprite object.
 */
class Shape extends Sprite
{
    public var lineWidth(default, default) :Float;
    public var lineCap(default, default) :LineCaps;
    public var strokeColor(default, default) :Int;
    public var fillColor(default, default) :Int;
    public var penCoordinate(default, null) :Point;
    
    private var _segments :Array<Segment>;
   

    public function new()
    {
        super();
        
        lineWidth = 1.0;
        lineCap = None;
        strokeColor = 0x000000;
        fillColor = 0xFFFFFF;
        penCoordinate = new Point();
        
        _segments = new Array<Segment>();
    }

    public function lineStyle(width :Float, color :Int, cap :LineCaps) : Void
    {
        lineWidth = width;
        strokeColor = color;
        lineCap = cap;
    }
    
    public function fillStyle(color :Int) : Void
    {
        fillColor = color;
    }
    
    public function moveTo(x :Float, y :Float) : Void
    {
        penCoordinate.set(x, y);
    }
    
    public function lineTo(x :Float, y :Float) : Void
    {
        var startPoint :Point = new Point(penCoordinate.x, penCoordinate.y);
        penCoordinate.set(x, y);
        
        trace(startPoint);
        
        var index = _segments.length;
        _segments[index] = new Segment(startPoint, penCoordinate, lineWidth, lineCap, strokeColor);
    }
    
    public function curveTo(anchorX :Float, anchorY :Float, x :Float, y :Float) : Void
    {
        // Determine how much percision
        var iPercInterval = 0.1;    // 0.1 == 10 vertices
        
        var i :Float = 0.0;
        var xa, ya, xb, yb;
        while (i < 1.0) {
            // Compute anchor/path
            xa = FMath.lerp(penCoordinate.x, anchorX, i);
            ya = FMath.lerp(penCoordinate.y, anchorY, i);
            xb = FMath.lerp(anchorX, x, i );
            yb = FMath.lerp(anchorY, y, i );

            // Find position along the anchor/path
            lineTo(FMath.lerp(xa, xb, i), FMath.lerp(ya, yb, i));
            
            i += iPercInterval;
        }
    }
    
    public function drawCircle(x :Float, y :Float, radius :Float) : Void
    {
        var numWedges :Int = Std.int(radius / 2);
        if (numWedges < 12) numWedges = 12;

        var wedgeAngle :Float = (2.0 * Math.PI) / numWedges;
        
        moveTo(x + radius, y);
        var theta :Float = 0.0;
        for (i in 0...numWedges)
        {
            theta = i * wedgeAngle;
            lineTo(x + radius * Math.cos(theta), y + radius * Math.sin(theta));
        }
    }
    
    public function drawEllipse(x :Float, y :Float, width :Float, height :Float, ?rotation :Float) : Void
    {
    }
    
    public function drawRect(x :Float, y :Float, width :Float, height :Float) : Void
    {
        moveTo(x, y);
        lineTo(x + width, y);
        lineTo(x + width, y + height);
        lineTo(x, y + height);
        lineTo(x, y);
    }
    
    public function clear() : Void
    {
        _segments = new Array<Segment>();
    }

    override public function draw (g :Graphics)
    {
        for (seg in _segments) {
            g.drawLine(seg.color, seg.startPt.x, seg.startPt.y, seg.endPt.x, seg.endPt.y, seg.width, seg.cap == Rounded);
        }
    }
}

private class Segment
{
    public var startPt(default, null) :Point;
    public var endPt(default, null) :Point;
    public var width(default, null) :Float;
    public var cap(default, null) :LineCaps;
    public var color(default, null) :Int;

    public function new(startPoint :Point, endPoint :Point, lineWidth :Float, lineCap :LineCaps, clr :Int)
    {
        startPt = new Point(startPoint.x, startPoint.y);
        endPt = new Point(endPoint.x, endPoint.y);
        
        width = lineWidth;
        cap = lineCap;
        
        color = clr;
    }
}