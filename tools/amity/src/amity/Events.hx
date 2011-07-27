//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package amity;

typedef AmityMouseEvent = {
    var x :Int;
    var y :Int;
}

@:native("__amity.events")
extern class Events
{
    public static var onMouseDown :AmityMouseEvent -> Void;
    public static var onMouseMove :AmityMouseEvent -> Void;
    public static var onMouseUp :AmityMouseEvent -> Void;

    public static var onEnterFrame :Int -> Void;
}
