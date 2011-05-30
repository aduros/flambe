package shooter;

import flambe.Component;

class Hull extends Component
{
    public var radius :Float;
    public var health (default, null) :Int;

    public function new (radius :Float, health :Int)
    {
        this.radius = radius;
        this.health = health;
    }

    public function damage (amount :Int) :Bool
    {
        if (health <= amount) {
            Game.enemies.remove(owner);
            owner.dispose();
            return true;
        } else {
            health -= amount;
            return false;
        }
    }
}
