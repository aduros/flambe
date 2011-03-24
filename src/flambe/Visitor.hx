package flambe;

import flambe.display.Sprite;

interface Visitor
{
    function enterEntity (entity :Entity) :Void;
    function leaveEntity (entity :Entity) :Void;

    function acceptComponent (comp :Component) :Void;

    // function acceptUpdatable
    function acceptSprite (sprite :Sprite) :Void;
}
