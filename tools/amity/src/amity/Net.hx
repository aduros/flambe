//
// Flambe - Rapid game development
// https://github.com/aduros/amity/blob/master/LICENSE.txt

package amity;

typedef HttpRequest = {
    var onStatus :Int -> Void;
    var onComplete :String -> Void;
    var onError :String -> Void;

    function setHeader (header :String, value :String) :Void;

    function send (postData :String) :Void;
}

@:native("__amity.net")
extern class Net
{
    public static function createHttpRequest (url :String) :HttpRequest;
}
