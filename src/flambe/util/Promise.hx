//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

/**
 * Represents a value that isn't ready yet, but may become available in the future.
 */
class Promise<A>
{
    /**
     * The end result fulfilled by the promise. When accessing, throws an error if the result is not
     * yet available. Read hasResult to check availability first, or use get(). When setting, throws
     * an error if the result was already previously assigned.
     */
    public var result (get, set) :A;

    /**
     * Whether the result is available yet.
     */
    public var hasResult (default, null) :Bool;

    /**
     * Emitted when the promise is fulfilled and the result has become available.
     */
    public var success (default, null) :Signal1<A>;

    /**
     * An error message emitted if there was a problem during loading.
     */
    public var error (default, null) :Signal1<String>;

    /**
     * May be emitted during loading when the progress or total counts have been updated.
     */
    public var progressChanged (default, null) :Signal0;

    /**
     * Context on how close this promise is to being fulfilled. For file IO, these are in bytes.
     */
    public var progress (get, set) :Float;
    public var total (get, set) :Float;

    public function new ()
    {
        success = new Signal1();
        error = new Signal1();
        progressChanged = new Signal0();
        hasResult = false;
        _progress = 0;
        _total = 0;
    }

    private function get_result () :A
    {
        if (!hasResult) {
            throw "Promise result not yet available";
        }
        return _result;
    }

    private function set_result (result :A) :A
    {
        if (hasResult) {
            throw "Promise result already assigned";
        }

        _result = result;
        hasResult = true;
        success.emit(result);
        return result;
    }

    /**
     * Passes the result to the callback now if the result is available, otherwise calls it later.
     * @returns If the callback was not called yet, a handle that can be disposed to cancel the
     * request.
     */
    public function get (fn :A -> Void) :Disposable
    {
        if (hasResult) {
            fn(_result);
            return null;
        }
        return success.connect(fn).once();
    }

    inline private function get_progress () :Float
    {
        return _progress;
    }

    private function set_progress (progress :Float) :Float
    {
        if (_progress != progress) {
            _progress = progress;
            progressChanged.emit();
        }
        return progress;
    }

    private function set_total (total :Float) :Float
    {
        if (_total != total) {
            _total = total;
            progressChanged.emit();
        }
        return total;
    }

    inline private function get_total () :Float
    {
        return _total;
    }

    private var _result :A;
    private var _progress :Float;
    private var _total :Float;
}
