//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.util.Disposable;
import flambe.util.Signal0;
import flambe.util.Signal1;
import flambe.util.Signal2;

/**
 * A component that manages a set of Disposable objects. When this component is disposed, all
 * attached Disposables are disposed as well.
 */
class Disposer extends Component
{
    public function new ()
    {
        _disposables = [];
    }

    /**
     * Add a Disposable, so that it also gets disposed when this component does.
     */
    public function add (disposable :Disposable)
    {
        _disposables.push(disposable);
    }

    /**
     * Remove a Disposable from this disposer.
     */
    public function remove (disposable :Disposable) :Bool
    {
        return _disposables.remove(disposable);
    }

    /**
     * Convenience method for connecting a signal listener and adding its SignalConnection to this
     * disposer.
     */
    public function connect0 (signal :Signal0, listener :Listener0)
    {
        add(signal.connect(listener));
    }

    /**
     * Convenience method for connecting a signal listener and adding its SignalConnection to this
     * disposer.
     */
    public function connect1<A> (signal :Signal1<A>, listener :Listener1<A>)
    {
        add(signal.connect(listener));
    }

    /**
     * Convenience method for connecting a signal listener and adding its SignalConnection to this
     * disposer.
     */
    public function connect2<A,B> (signal :Signal2<A,B>, listener :Listener2<A,B>)
    {
        add(signal.connect(listener));
    }

    override public function onDispose ()
    {
        var disposables = _disposables;
        _disposables = [];
        for (d in disposables) {
            d.dispose();
        }
    }

    private var _disposables :Array<Disposable>;
}
