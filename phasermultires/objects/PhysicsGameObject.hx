package phasermultires.objects;
import phaser.core.Group;
import phaser.geom.Rectangle;
import phaser.physics.p2.Body;

class PhysicsGameObject extends GameObject
{
	public var body:Body;
	
	public var offX:Float = 0;
	public var offY:Float = 0;
	
	public function new(?group:Group = null) 
	{
		super(group);
	}
	
	override public function initialize():Void
	{
		super.initialize();
		doPhysics();
	}
	
	public static  var debugscaleX:Float = 20;
	public static  var debugscaleY:Float = 20;
	
	override public function update():Void
	{
		super.update();
		if (sprite != null) {
			sprite.x = this.x;
			sprite.y = this.y;
		}
		
		if(game.config.enableDebug) {
				game.debug.geom(new Rectangle(body.x * debugscaleX, body.y * debugscaleY, body.data.shapes[0].width * debugscaleX , body.data.shapes[0].height * debugscaleY),"red",false);
		}
	}
	
	public function doPhysics()
	{
		createBody();
		untyped  body.data.userData = this;
		game.physics.p2.addBody(body);
		body.onBeginContact.add(onBeginContact);
		body.onEndContact.add(onEndContact);
	}
	
	function onBeginContact(body:Body,shape1:Dynamic,shape2:Dynamic,contact:Dynamic):Void{}
	
	function onEndContact(body:Body, shape1:Dynamic, shape2:Dynamic, contact:Dynamic):Void { }
	
	function body2GameObject(body:Body):PhysicsGameObject { return body.data.userData; }
	
	function createBody()
	{
		body = new Body(game);
	}
	
	override public function destroy()
	{
		if (body != null) {
			body.removeNextStep  = true;
			body.onBeginContact.remove(onBeginContact);
			body.onEndContact.remove(onEndContact);
			//body.destroy();
		}
		super.destroy();
	}
	
	override public function get_x() {
		return this.x;
	 }

	override public function set_x(x):Float {
		if (body != null) {
			this.x = x;
			body.x = body.world.pxm(x + offX);
			return x;
		}
		else
			return this.x = x;
	}
	
	override public function get_y() {
		return this.y;
	 }

	override public function set_y(y):Float {
		if (body != null) {
			this.y = y;
			body.y = body.world.pxm(y + offY);
			return y;
		}
		else
			return this.y = y;
	}
	
}