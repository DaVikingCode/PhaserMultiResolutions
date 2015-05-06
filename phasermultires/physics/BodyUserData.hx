package phasermultires.physics;
import phasermultires.objects.PhysicsGameObject;

class BodyUserData
{
	public var gameObject:PhysicsGameObject;
	public var id:String;
	public var data:Dynamic;
	public function new(gameObject:PhysicsGameObject,id:String,?data:Dynamic = null) {
		this.gameObject = gameObject;
		this.id = id;
		this.data = data;
	}
	
}