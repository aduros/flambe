//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.display.Sprite;
import flambe.math.Point;
import flambe.util.Assert;

/**
 * A user defined shape (line, rectangle, polygon) that is assembled by adding
 * various primitives together. Can be transformed like any Sprite object.
 */
class Shape extends Sprite
{
    public var color(default, default) :Int;
    private var segments :Array<Segment>;

    public function new()
    {
        super();

        color = 0x000000;
        segments = new Array<Segment>();
    }

    /**
     * Adds a line segment to this shape. The coordinates specified are local to the Shape's origin.
     * @returns This instance, for chaining.
     */
    public function addLineSegmentF(xStart :Float, yStart :Float, xEnd :Float, yEnd :Float, width :Float, ?roundedCap :Bool = false) :Shape
    {
        var index = segments.length;
        segments[index] = new Segment(xStart, yStart, xEnd, yEnd, width, roundedCap);

        return this;
    }

    /**
     * Adds a line segment to this shape. The coordinates specified are local to the Shape's origin.
     * @returns This instance, for chaining.
     */
    public function addLineSegment(ptStart :Point, ptEnd :Point, width :Float, ?roundedCap :Bool = false) :Shape
    {
        var index = segments.length;
        segments[index] = new Segment(ptStart.x, ptStart.y, ptEnd.x, ptEnd.y, width, roundedCap);

        return this;
    }

    /**
     * Adds a contiguous line strip to this shape. The coordinates specified are local to the Shape's origin.
     * @returns This instance, for chaining.
     */
    public function addLineStrip(ptArray :Array<Point>, width :Float, ?roundedCap :Bool = false)
    {
        Assert.that(ptArray.length >= 2, "addLineStrip() must have at least '2' Points");

        for(i in 1...ptArray.length) {
            addLineSegment(ptArray[i - 1], ptArray[i], width, roundedCap);
        }

        return this;
    }

    override public function draw (g :Graphics)
    {
        for (seg in segments) {
            seg.draw(g, color);
        }
    }
}

private class Segment
{
    public var ptStart :Point;
    public var ptEnd :Point;
    public var width :Float;
    public var roundedCap :Bool;

    public function new(xStart :Float, yStart :Float, xEnd :Float, yEnd :Float, width :Float, roundedCap :Bool)
    {
        ptStart = new Point(xStart, yStart);
        ptEnd = new Point(xEnd, yEnd);
        this.width = width;
        this.roundedCap = roundedCap;
    }

    public function draw (g :Graphics, color :Int)
    {
        g.drawLine(color, ptStart.x, ptStart.y, ptEnd.x, ptEnd.y, width, roundedCap);
    }
}