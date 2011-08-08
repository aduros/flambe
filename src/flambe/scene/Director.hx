//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.scene;

import flambe.Component;
import flambe.Visitor;

class Director extends Component
{
    public var topScene (getTopScene, null) :Entity;

    public var scenes (default, null) :Array<Entity>;

    public function new ()
    {
        scenes = [];
    }

    public function pushScene (scene :Entity)
    {
        if (scenes.length > 0) {
            emitHidden(topScene);
        }
        scenes.push(scene);
        emitShown();
    }

    public function popScene ()
    {
        var scene = scenes.pop();
        if (scene != null) {
            emitHidden(scene);
            scene.dispose();

            if (scenes.length > 0) {
                emitShown();
            }
        }
    }

    public function unwindToScene (scene :Entity)
    {
        if (topScene == scene) {
            return;
        }

        if (scenes.length > 0) {
            var oldTop = scenes.pop();
            emitHidden(oldTop);
            oldTop.dispose();

            while (scenes.length > 0) {
                if (topScene != scene) {
                    scenes.pop().dispose();
                } else {
                    emitShown();
                    return;
                }
            }
        }

        scenes.push(scene);
        emitShown();
    }

    override public function onDispose ()
    {
        for (scene in scenes) {
            scene.dispose();
        }
        scenes = [];
    }

    override public function visit (visitor :Visitor)
    {
        visitor.acceptComponent(this);
        if (scenes.length > 0) {
            topScene.visit(visitor, true, true);
        }
    }

    inline private function getTopScene ()
    {
        return scenes[scenes.length-1];
    }

    private function emitShown ()
    {
        var events = topScene.get(Scene);
        if (events != null) {
            events.shown.emit();
        }
    }

    private function emitHidden (scene :Entity)
    {
        var events = scene.get(Scene);
        if (events != null) {
            events.hidden.emit();
        }
    }
}
