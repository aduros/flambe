//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe;

import flambe.util.Disposable;
import flambe.util.Signal0;
import flambe.util.Signal1;
import flambe.util.Signal2;

/**
 * A component that manages a set of Disposable objects. When this component is removed from its
 * owner, all managed Disposables are disposed.
 */
class Disposer extends Component
{
    public function new ()
    {
        _disposables = [];
    }

    /**
     * Add a Disposable, so that it also gets disposed when this component does.
     * @returns This instance, for chaining.
     */
    public function add (disposable :Disposable) :Disposer
    {
        _disposables.push(disposable);
        return this;
    }

    /**
     * Remove a Disposable from this disposer.
     * @returns True if the disposable was removed.
     */
    public function remove (disposable :Disposable) :Bool
    {
        return _disposables.remove(disposable);
    }

    /**
     * Chainable convenience method for connecting a signal listener and adding its SignalConnection
     * to this disposer.
     * @returns This instance, for chaining.
     */
    public function connect0 (signal :Signal0, listener :Listener0) :Disposer
    {
        add(signal.connect(listener));
        return this;
    }

    /**
     * Chainable convenience method for connecting a signal listener and adding its SignalConnection
     * to this disposer.
     * @returns This instance, for chaining.
     */
    public function connect1<A> (signal :Signal1<A>, listener :Listener1<A>) :Disposer
    {
        add(signal.connect(listener));
        return this;
    }

    /**
     * Chainable convenience method for connecting a signal listener and adding its SignalConnection
     * to this disposer.
     * @returns This instance, for chaining.
     */
    public function connect2<A,B> (signal :Signal2<A,B>, listener :Listener2<A,B>) :Disposer
    {
        add(signal.connect(listener));
        return this;
    }

    override public function onRemoved ()
    {
        freeDisposables();
    }

    override public function dispose ()
    {
        super.dispose();
        freeDisposables(); // Cleanup even if this component had no owner
    }

    private function freeDisposables ()
    {
        var snapshot = _disposables;
        _disposables = [];
        for (disposable in snapshot) {
            disposable.dispose();
        }
    }

    private var _disposables :Array<Disposable>;
}
