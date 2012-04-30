//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.scene;

import flambe.Component;
import flambe.Visitor;

class Director extends Component
{
    /** The front-most scene. */
    public var topScene (getTopScene, null) :Entity;

    /** The complete list of scenes managed by this director, from back to front. */
    public var scenes (default, null) :Array<Entity>;

    /** The list of scenes that are not occluded by an opaque scene, from back to front. */
    public var visibleScenes (default, null) :Array<Entity>;

    public function new ()
    {
        scenes = [];
        visibleScenes = [];
    }

    public function pushScene (scene :Entity)
    {
        if (scenes.length > 0) {
            emitHidden(topScene);
        }
        scenes.push(scene);
        invalidateVisibility();
    }

    public function popScene ()
    {
        var scene = scenes.pop();
        if (scene != null) {
            emitHidden(scene);
            scene.dispose();
            invalidateVisibility();
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
                    invalidateVisibility();
                    return;
                }
            }
        }

        scene._internal_setParent(owner);
        scenes.push(scene);
        invalidateVisibility();
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

    private function emitHidden (scene :Entity)
    {
        var events = scene.get(Scene);
        if (events != null) {
            events.hidden.emit();
        }
    }

    private function invalidateVisibility ()
    {
        // Find the last index of an opaque scene, or 0
        var ii = scenes.length;
        while (ii > 0) {
            var scene = scenes[--ii];
            var comp = scene.get(Scene);
            if (comp == null || comp.opaque) {
                break;
            }
        }
        visibleScenes = scenes.slice(ii, scenes.length);

        // Notify the new top scene that it's being shown
        if (scenes.length > 0) {
            var events = topScene.get(Scene);
            if (events != null) {
                events.shown.emit();
            }
        }
    }
}
