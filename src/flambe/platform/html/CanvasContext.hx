package flambe.platform.html;

import js.html.CanvasElement;

class CanvasContext
{
    public var canvas(default, null):CanvasElement;

    public var shared(default, null):Bool;

    public function new(canvas:CanvasElement, ?shared = false)
    {
      this.canvas = canvas;
      this.shared = shared;
    }
}