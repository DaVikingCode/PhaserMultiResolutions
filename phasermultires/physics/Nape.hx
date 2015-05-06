package phasermultires.physics;
import nape.callbacks.InteractionCallback;
import nape.geom.Vec2;
import nape.phys.Interactor;
import nape.space.Space;
import phaser.core.Group;
import phasermultires.objects.GameObject;
import phasermultires.objects.PhysicsGameObject;

class Nape extends GameObject
{
	public var space:Space;
	var interactionListener:NapeInteractionListener; 
	
	public function new(?group:Group = null)  
	{
		super(group);
		enableUpdate = true;
		
		space = new Space(Vec2.get(0, 0));
		interactionListener = new NapeInteractionListener(space);
	}
	
	override public function initialize()
	{
		super.initialize();
	}
	
	override public function update()
	{
		space.step(1 / 30);
		super.update();
	}
	
	override public function destroy()
	{
		interactionListener.destroy();
		interactionListener = null;
		space.clear();
		space = null;
		super.destroy();
	}
	
	/**
	 * Get this body user data, as one PhysicsGameObject can have many bodies and can be identified by BodyUserData.id or have a different BodyUserData.data
	 * @param	self
	 * @param	callback
	 * @return
	 */
	static public function getThisBodyUserData(self:PhysicsGameObject, callback:InteractionCallback):BodyUserData {
			return self == cast(callback.int1.userData.bodyUserData, BodyUserData).gameObject ? cast(callback.int1.userData.bodyUserData, BodyUserData) : cast(callback.int2.userData.bodyUserData, BodyUserData);
	}
	
	/**
	 * Get the BodyUserData of the object we collide with.
	 * @param	self
	 * @param	callback
	 * @return
	 */
	static public function getOtherBodyUserData(self:PhysicsGameObject, callback:InteractionCallback):BodyUserData {
			return self == cast(callback.int1.userData.bodyUserData, BodyUserData).gameObject ? cast(callback.int2.userData.bodyUserData, BodyUserData) : cast(callback.int1.userData.bodyUserData, BodyUserData);
	}
	
}