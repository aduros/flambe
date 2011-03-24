package flambe;

@:autoBuild(flambe.macro.Build.buildComponent())
class Component
{
    public var owner (default, null) :Entity;

    public function getName () :String
    {
        return null; // Is this really required?
    }

    public function onAttach (owner :Entity)
    {
        this.owner = owner;
    }

    public function onDetach ()
    {
        owner = null;
    }

    public function update (dt :Int)
    {
        // Nothing
    }

    public function visit (visitor :Visitor)
    {
        // Nothing
    }
}
