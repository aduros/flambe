package amity;

typedef HttpRequest = {
    var onStatus :Int -> Void;
    var onComplete :String -> Void;
    var onError :String -> Void;

    function setHeader (header :String, value :String) :Void;

    function start (url :String, post :Bool) :Void;
}

@:native("__amity.net")
extern class Net
{
    public static function createHttpRequest () :HttpRequest;
}
