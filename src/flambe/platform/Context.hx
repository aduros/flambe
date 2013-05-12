package flambe.platform;

typedef Context =
#if flash
    flambe.platform.flash.Stage3DContext;
#elseif html
    flambe.platform.html.CanvasContext;
#else
    #error
#end