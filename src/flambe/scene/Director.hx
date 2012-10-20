//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.scene;

import flambe.Component;
import flambe.Visitor;

/**
 * Manages a stack of scenes. Only the front-most scene receives game updates.
 */
class Director extends Component
{
    /** The front-most scene. */
    public var topScene (getTopScene, null) :Entity;

    /** The complete list of scenes managed by this director, from back to front. */
    public var scenes (default, null) :Array<Entity>;

    /** The list of scenes that are not occluded by an opaque scene, from back to front. */
    public var visibleScenes (default, null) :Array<Entity>;

    /** Whether the director is currently transitioning between scenes. */
    public var transitioning (isTransitioning, null) :Bool;

    public function new ()
    {
        scenes = [];
        visibleScenes = [];
    }

    public function pushScene (scene :Entity, ?transition :Transition)
    {
        completeTransition();

        if (scenes.length > 0) {
            var oldTop = topScene;
            playTransition(oldTop, scene, transition, function () {
                add(scene);
                hide(oldTop);
            });
        } else {
            add(scene);
            invalidateVisibility();
        }
    }

    public function popScene (?transition :Transition)
    {
        completeTransition();

        if (scenes.length > 0) {
            var oldTop = topScene;
            if (scenes.length > 1) {
                var newTop = scenes[scenes.length-2];
                playTransition(oldTop, newTop, transition, function () {
                    hideAndDispose(scenes.pop());
                });
            } else {
                hideAndDispose(scenes.pop());
                invalidateVisibility();
            }
        }
    }

    /**
     * Pops the scene stack until the given entity is the top scene, or adds the scene if the stack
     * becomes empty while popping.
     */
    public function unwindToScene (scene :Entity, ?transition :Transition)
    {
        completeTransition();

        if (scenes.length > 0) {
            var oldTop = topScene;
            if (oldTop == scene) {
                return; // We're already there
            }

            playTransition(oldTop, scene, transition, function () {
                var oldTop = scenes.pop();
                while (scenes.length > 0 && topScene != scene) {
                    scenes.pop().dispose(); // Don't emit a hide, just dispose them
                }
                if (scenes.length == 0) {
                    add(scene);
                }
                hideAndDispose(oldTop);
            });

        } else {
            pushScene(scene, transition);
        }
    }

    override public function onDispose ()
    {
        for (scene in scenes) {
            scene.dispose();
        }
        scenes = [];

        if (_transitor != null) {
            _transitor.dispose();
            _transitor = null;
        }
    }

    override public function onUpdate (dt :Float)
    {
        if (_transitor != null && _transitor.update(dt)) {
            completeTransition();
        }
    }

    override public function visit (visitor :Visitor)
    {
        visitor.acceptComponent(this);

        if (_transitor != null) {
            _transitor.visit(visitor);
        } else {
            if (scenes.length > 0) {
                topScene.visit(visitor, true, true);
            }
        }
    }

    inline private function getTopScene () :Entity
    {
        return scenes[scenes.length-1];
    }

    inline private function isTransitioning () :Bool
    {
        return _transitor != null;
    }

    private function add (scene :Entity)
    {
        scenes.push(scene);
        scene._internal_setParent(owner);
    }

    private function hide (scene :Entity)
    {
        var events = scene.get(Scene);
        if (events != null) {
            events.hidden.emit();
        }
    }

    private function hideAndDispose (scene :Entity)
    {
        hide(scene);
        scene.dispose();
    }

    private function show (scene :Entity)
    {
        var events = scene.get(Scene);
        if (events != null) {
            events.shown.emit();
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
            show(topScene);
        }
    }

    // Notes:
    // - Any method that modifies the scene stack should immediately call completeTransition.
    // - If a transition is used, the method should only modify the stack in onComplete.
    private function completeTransition ()
    {
        if (_transitor != null) {
            _transitor.complete();
            _transitor = null;

            invalidateVisibility();
        }
    }

    private function playTransition (from :Entity, to :Entity,
        transition :Transition, onComplete :Void->Void)
    {
        completeTransition();

        if (transition != null) {
            // Ensure the scene being transitioned to is rendered on top
            visibleScenes.remove(to);
            visibleScenes.push(to);

            _transitor = new Transitor(from, to, transition, onComplete);
            _transitor.init();
        } else {
            onComplete();
            invalidateVisibility();
        }
    }

    private var _transitor :Transitor;
}

private class Transitor
{
    public function new (from :Entity, to :Entity, transition :Transition, onComplete :Void->Void)
    {
        _from = from;
        _to = to;
        _transition = transition;
        _onComplete = onComplete;
    }

    public function init ()
    {
        _transition.init(_from, _to);
    }

    public function visit (visitor :Visitor)
    {
        // _from.visit(visitor, true, true);
        _to.visit(visitor, true, true);
    }

    public function update (dt :Float) :Bool
    {
        return _transition.update(dt);
    }

    public function complete ()
    {
        _transition.complete();
        _onComplete();
    }

    public function dispose ()
    {
        _from.dispose();
        _to.dispose();
    }

    private var _from :Entity;
    private var _to :Entity;
    private var _transition :Transition;

    private var _onComplete :Void->Void;
}
