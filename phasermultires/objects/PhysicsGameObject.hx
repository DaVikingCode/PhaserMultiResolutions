package phasermultires.objects;
import nape.callbacks.InteractionCallback;
import nape.geom.Geom;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Shape;
import phaser.core.Group;
import phaser.gameobjects.Sprite;
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
		
		if(game.config.enableDebug && body!= null) {
				game.debug.geom(
				new Rectangle((body.position.x - body.bounds.width/2 + shapeTranslate.x) * debugScaleX + debugOffX, (body.position.y - body.bounds.height/2 + shapeTranslate.y) * debugScaleY + debugOffY, body.bounds.width * debugScaleX, body.bounds.height * debugScaleY),debugArtColor,false);
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
	
	public function intersects(other:PhysicsGameObject):Bool
	{
		return Geom.intersectsBody(this.body, other.body);
	}
	
	public function contains(other:PhysicsGameObject):Bool
	{
		return Geom.contains(this.shape, other.shape);
	}
	
	public function onBeginContact(interaction:InteractionCallback):Void{}
	
	public function onEndContact(interaction:InteractionCallback):Void{}
	
	function createBody()
	{
		body = new Body(BodyType.KINEMATIC,Vec2.weak(this.x,this.y));
	}
	
	public static function bodyFactory(sprite:Sprite,space:nape.space.Space, type:BodyType, sensor:Bool, ?position:Vec2 = null, ?rect:Rectangle = null,?b:Body = null):Dynamic
	{
		var d:Dynamic = {body:null, shape:null, shapeTranslate:null };
		
		if (position == null)
			position = Vec2.weak();
			
		var w:Float = sprite.width;
		var h:Float = sprite.height;
		
		if (rect != null)
		{
			w = rect.width;
			h = rect.height;
		}
		
		if(b == null)
			b = new Body(type, position);
		else
		{
			b.shapes.clear();
		}
		
		var shape:Shape = new nape.shape.Polygon(nape.shape.Polygon.box(w, h));
		
		var pivotX:Float = sprite.pivot.x * sprite.scale.x;
		var pivotY:Float = sprite.pivot.y * sprite.scale.y;
		
		var shapeTranslate:Vec2 = Vec2.get(-pivotX + w/2 , -pivotY + h/2 );
		
		if (rect != null)
		{
			shapeTranslate.x += rect.x;
			shapeTranslate.y += rect.y;
		}
		
		shape.sensorEnabled = sensor;
		b.shapes.add(shape);
		b.space = null;
		b.translateShapes(shapeTranslate);
		b.space = space;
		
		d.body = b;
		d.shape = shape;
		d.shapeTranslate = shapeTranslate;
		
		return d;
	}
	
	override public function destroy()
	{
		shapeTranslate.dispose();
		if (body != null) {
			if(Reflect.hasField(body.userData,"bodyUserData") && body.userData.bodyUserData != null)
				body.userData.bodyUserData.destroy();
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