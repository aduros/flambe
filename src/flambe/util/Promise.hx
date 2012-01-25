//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

class Promise<A>
{
    /**
     * The end result fulfilled by the promise. When accessing, throws an error if the result is not
     * yet available. Read hasResult to check availability first, or use get(). When setting, throws
     * an error if the result was already previously assigned.
     */
    public var result (getResult, setResult) :A;

    /**
     * Whether the result is available yet.
     */
    public var hasResult (default, null) :Bool;

    public var success (default, null) :Signal1<A>;
    public var error (default, null) :Signal1<String>;
    public var progressChanged (default, null) :Signal0;

    // Context on how close this promise is to being fulfilled. For file IO, these are in bytes.
    public var progress (getProgress, setProgress) :Float;
    public var total (getTotal, setTotal) :Float;

    public function new ()
    {
        success = new Signal1();
        error = new Signal1();
        progressChanged = new Signal0();
        hasResult = false;
        _progress = 0;
        _total = 0;
    }

    private function getResult () :A
    {
        if (!hasResult) {
            throw "Promise result not yet available";
        }
        return _result;
    }

    private function setResult (result :A) :A
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
     * Retrieve the result if available, otherwise receive it later.
     */
    public function get (fn :A -> Void)
    {
        if (hasResult) {
            fn(_result);
        } else {
            success.connect(fn).once();
        }
    }

    inline private function getProgress () :Float
    {
        return _progress;
    }

    private function setProgress (progress :Float) :Float
    {
        _progress = progress;
        progressChanged.emit();
        return progress;
    }

    private function setTotal (total :Float) :Float
    {
        _total = total;
        progressChanged.emit();
        return total;
    }

    inline private function getTotal () :Float
    {
        return _total;
    }

    private var _result :A;
    private var _progress :Float;
    private var _total :Float;
}
