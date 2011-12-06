//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.util;

class Promise<A>
{
    public var result (default, setResult) :A;

    public var success (default, null) :Signal1<A>;
    public var error (default, null) :Signal1<String>;
    public var progressChanged (default, null) :Signal0;

    // Context on how close this promise is to being fulfilled. For file IO, these are in bytes.
    public var progress (getProgress, setProgress) :Float;
    public var total (getTotal, setTotal) :Float;

    public function new ()
    {
        this.success = new Signal1();
        this.error = new Signal1();
        this.progressChanged = new Signal0();
        _progress = 0;
        _total = 0;
    }

    private function setResult (result :A) :A
    {
        if (result == null) {
            throw "Promise result cannot be null";
        }

        if (this.result == null) {
            this.result = result;
            success.emit(result);
        }
        return result;
    }

    /** Retrieve the value if available, otherwise receive it later. */
    public function get (fn :A -> Void)
    {
        if (this.result == null) {
            success.connect(fn).once();
        } else {
            fn(this.result);
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

    private var _progress :Float;
    private var _total :Float;
}
