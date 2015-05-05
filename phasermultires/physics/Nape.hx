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
	
	static public function getOtherInteractor(self:PhysicsGameObject, callback:InteractionCallback):Interactor {
			return self == callback.int1.userData.myData ? callback.int2 : callback.int1;
		}
	
}