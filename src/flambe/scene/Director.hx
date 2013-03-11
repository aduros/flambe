//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.scene;

import flambe.Component;

/**
 * Manages a stack of scenes. Only the front-most scene receives game updates.
 */
// TODO(bruno): Major robustness cleanup and testing needed here
class Director extends Component
{
    /** The front-most scene. */
    public var topScene (get, null) :Entity;

    /** The complete list of scenes managed by this director, from back to front. */
    public var scenes (default, null) :Array<Entity>;

    /**
     * The scenes that are partially occluded by a transparent or transitioning scene, from back to
     * front. These scenes are not updated, but they're still drawn.
     */
    public var occludedScenes (default, null) :Array<Entity>;

    /** Whether the director is currently transitioning between scenes. */
    public var transitioning (get, null) :Bool;

    /** The ideal width of the director's scenes. Used by some transitions. */
    public var width (get, null) :Float;

    /** The ideal height of the director's scenes. Used by some transitions. */
    public var height (get, null) :Float;

    public function new ()
    {
        scenes = [];
        occludedScenes = [];
        _root = new Entity();
    }

    /**
     * Sets the ideal size of the scenes in this director. By default, the size is the full stage
     * width and height. This size is used by some transitions, such as SlideTransition.
     */
    public function setSize (width :Float, height :Float) :Director
    {
        _width = width;
        _height = height;
        return this;
    }

    public function pushScene (scene :Entity, ?transition :Transition)
    {
        completeTransition();

        var oldTop = get_topScene();
        if (oldTop != null) {
            playTransition(oldTop, scene, transition, function () {
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

        var oldTop = get_topScene();
        if (oldTop != null) {
            scenes.pop(); // Pop oldTop
            var newTop = get_topScene();
            if (newTop != null) {
                playTransition(oldTop, newTop, transition, function () {
                    hideAndDispose(oldTop);
                });
            } else {
                hideAndDispose(oldTop);
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

        var oldTop = get_topScene();
        if (oldTop != null) {
            if (oldTop == scene) {
                return; // We're already there
            }

            scenes.pop(); // Pop oldTop
            while (scenes.length > 0 && scenes[scenes.length-1] != scene) {
                scenes.pop().dispose(); // Don't emit a hide, just dispose them
            }

            playTransition(oldTop, scene, transition, function () {
                hideAndDispose(oldTop);
            });

        } else {
            pushScene(scene, transition);
        }
    }

    override public function onAdded ()
    {
        owner.addChild(_root);
    }

    override public function onRemoved ()
    {
        completeTransition();

        for (scene in scenes) {
            scene.dispose();
        }
        scenes = [];
        occludedScenes = [];

        _root.dispose();
    }

    override public function onUpdate (dt :Float)
    {
        if (_transitor != null && _transitor.update(dt)) {
            completeTransition();
        }
    }

    private function get_topScene () :Entity
    {
        var ll = scenes.length;
        return (ll > 0) ? scenes[ll-1] : null;
    }

    inline private function get_transitioning () :Bool
    {
        return _transitor != null;
    }

    private function add (scene :Entity)
    {
        var oldTop = get_topScene();
        if (oldTop != null) {
            _root.removeChild(oldTop);
        }

        scenes.remove(scene);
        scenes.push(scene);
        _root.addChild(scene);
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

        // All visible scenes up to, but not including, the top scene
        occludedScenes = (scenes.length > 0) ? scenes.slice(ii, scenes.length-1) : [];

        // Notify the new top scene that it's being shown
        var scene = get_topScene();
        if (scene != null) {
            show(scene);
        }
    }

    // Notes:
    // - Any method that modifies the scene stack should immediately call completeTransition.
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
        add(to);

        if (transition != null) {
            occludedScenes.push(from);

            _transitor = new Transitor(from, to, transition, onComplete);
            _transitor.init(this);
        } else {
            onComplete();
            invalidateVisibility();
        }
    }

    private function get_width () :Float
    {
        return (_width < 0) ? System.stage.width : _width;
    }

    private function get_height () :Float
    {
        return (_height < 0) ? System.stage.height : _height;
    }

    /** The container for the current scene. */
    private var _root :Entity;

    private var _transitor :Transitor = null;
    private var _width :Float = -1;
    private var _height :Float = -1;
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

    public function init (director :Director)
    {
        _transition.init(director, _from, _to);
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

    private var _from :Entity;
    private var _to :Entity;
    private var _transition :Transition;

    private var _onComplete :Void->Void;
}
