package phasermultires.objects;
import nape.callbacks.InteractionCallback;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Shape;
import phaser.core.Group;
import phaser.geom.Rectangle;
import phasermultires.physics.BodyUserData;
import phasermultires.physics.Nape;

class PhysicsGameObject extends GameObject
{
	public var body:Body;
	public var shape:Shape;
	public var nape:Nape;
	
	public static var debugScaleX:Float = 1;
	public static var debugScaleY:Float = 1;
	public static var debugOffX:Float = 0;
	public static var debugOffY:Float = 0;
	
	var shapeTranslate:Vec2 = Vec2.get();
	var debugArtColor:String = "green";
	
	var dirty:Bool = false;
	
	public function new(?group:Group = null) 
	{
		super(group);
	}
	
	override public function initialize():Void
	{
		super.initialize();
		nape = cast state.getObjectByType(Nape);
		doPhysics();
		
		body.align();
	}
	
	public static  var phScaleX:Float = 1;
	public static  var phScaleY:Float = 1;
	
	override public function update():Void
	{
		super.update();
		if (sprite != null && dirty) {
			sprite.x = this.x;
			sprite.y = this.y;
			dirty = false;
		}
		
		if(game.config.enableDebug) {
				game.debug.geom(
				new Rectangle((this.x - body.bounds.width/2 + shapeTranslate.x) * debugScaleX + debugOffX, (this.y- body.bounds.height/2 + shapeTranslate.y) * debugScaleY + debugOffY, body.bounds.width * debugScaleX, body.bounds.height * debugScaleY),debugArtColor,false);
		}
	}
	
	public function doPhysics()
	{
		createBody();
		if(sprite != null) {
		width = sprite.width;
		height = sprite.height;
		}
		body.userData.bodyUserData = new BodyUserData(this,"main");
		body.space = nape.space;
	}
	
	public function onBeginContact(interaction:InteractionCallback):Void{}
	
	public function onEndContact(interaction:InteractionCallback):Void{}
	
	function createBody()
	{
		body = new Body(BodyType.KINEMATIC,Vec2.weak(this.x,this.y));
	}
	
	override public function destroy()
	{
		shapeTranslate.dispose();
		if (body != null) {
			nape.space.bodies.remove(body);
			body.space = null;
		}
		super.destroy();
	}
	
	override public function get_x() {
			return this.x;
	 }

	override public function set_x(x):Float {
		if (body != null && body.position != null) {
			var pos:Vec2 = body.position ;
			this.x =  pos.x = x;
			body.position = pos;
			dirty = true;
			return x;
		}
		else
			return this.x = x;
	}
	
	override public function get_y() {
			return this.y;
	 }

	override public function set_y(y):Float {
		if (body != null && body.position != null) {
			var pos:Vec2 = body.position ;
			this.y = pos.y = y;
			body.position = pos;
			dirty = true;
			return y;
		}
		else
			return this.y = y;
	}
	
}