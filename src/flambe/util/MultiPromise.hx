//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

import flambe.Disposer;

/**
 * Multiplexes a list of promises into a single promise. When all promises have been fulfilled, the
 * success signal will be emitted with an array containing their respective results. Progress and
 * error signals are also aggregated.
 */
class MultiPromise extends Promise<Array<Dynamic>>
{
    public function new (promises :Array<Dynamic>)
    {
        super();
        _promises = cast promises.copy();
        _successCount = 0;
        _disposer = new Disposer();

        onProgressChanged();

        var snapshot = _promises;
        for (promise in snapshot) {
            _disposer.connect1(promise.error, onError);
            _disposer.connect0(promise.progressChanged, onProgressChanged);
            var pending = promise.get(onSuccess);
            if (pending != null) {
                _disposer.add(pending);
            }
        }
    }

    private function onSuccess (_)
    {
        if (_promises == null) {
            return;
        }
        ++_successCount;
        if (_successCount >= _promises.length) {
            var results = [];
            for (promise in _promises) {
                results.push(promise.result);
            }
            finalize();
            set_result(cast results);
        }
    }

    private function onError (message :String)
    {
        if (_promises == null) {
            return;
        }
        finalize();
        error.emit(message);
    }

    private function onProgressChanged ()
    {
        if (_promises == null) {
            return;
        }
        _progress = 0;
        _total = 0;
        for (promise in _promises) {
            _progress += promise.progress;
            _total += promise.total;
        }
        progressChanged.emit();
    }

    private function finalize ()
    {
        _disposer.dispose();
        _promises = null; // Marks that all promises are fulfilled, or there was an error
    }

    private var _promises :Array<Promise<Dynamic>>;
    private var _successCount :Int;
    private var _disposer :Disposer;
}
