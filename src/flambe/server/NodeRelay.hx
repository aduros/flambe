package flambe.server;

/**
 * Node uses callbacks in the form of function(error, result) as a standard
 * convention for asynchronous operations.
 */
typedef NodeCallback<A> = Dynamic -> A -> Void;

/**
 * Manages control flow for Node-style callbacks. Propagates the occurrence of
 * an error parameter to error(), and handles uncaught exceptions too. Quite
 * handy for remoting.
 *
 * <code>
 * var rsp :NodeRelay<String>;
 * // ...
 * db.doAsyncOperation(rsp.chain(function (result) {
 *     if (!validateResult(result)) {
 *         throw new Error("Validation failed");
 *     }
 *     db.moarAsync(rsp.chain(function (result) {
 *         rsp.success(result.name);
 *     }));
 * }));
 * </code>
 */
class NodeRelay<T>
{
    /**
     * The HTTP request this relay originated from.
     */
    public var request (default, null) :Dynamic;

    public function new (request :Dynamic)
    {
        this.request = request;
    }

    public dynamic function success (result :T) { }
    public dynamic function error (err :Dynamic) { }

    /**
     * Wraps a callback around a Node-style callback that does the right thing
     */
    public function chain<A> (f :A -> Void) :NodeCallback<A>
    {
        var self = this;
        return function (err, x :A) {
            if (err != null) {
                self.error(err);
            } else {
                try {
                    f(x);
                } catch (e :Dynamic) {
                    self.error(e);
                }
            }
        }
    }
}
