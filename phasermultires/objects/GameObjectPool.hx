package phasermultires.objects;
import haxe.macro.Type;
import phasermultires.Root;
import phasermultires.states.MultiResState;

class GameObjectPool
{
	var poolType:Dynamic;
	
	var growthRate:Int = 1;
	
	public var free:Array<Dynamic>;
	public var active:Array<Dynamic>;
	
	public var game:Root;
	public var state:MultiResState;
	
	public function new(?type:Dynamic = null,growthRate:Int = 1) 
	{
		if (type == null)
			poolType = GameObject;
		else
			poolType = type;
			
		free = new Array<Dynamic>();
		active = new Array<Dynamic>();
		gc = new Array<Dynamic>();
		
		game = Root.instance;
		state = game.getCurrentMultiResState();
		
		this.growthRate = 1;
	}
	
	public function initializePool(size:Int = 1)
	{
		increasePoolSize(size);
	}
	
	function createInstance():GameObject {
		var go:GameObject = new GameObject(state.container);
		return go;
	}
	
	function increasePoolSize(sizeIncrease:Int)
	{
		for (n in 0...sizeIncrease) 
		{
			var go:Dynamic = createInstance();
			
			if (!Std.is(go, poolType)) {
				trace("[GameObjectPool] error, object is not of right type.");
				continue;
			}
			
			_create(go);
			
			go.initialize();
			go.initialized = true;
			go.enableUpdate = true;
			
			_dispose(go);
			
			free.unshift(go);
		}
	}
	
	function move(object:Dynamic,from:Array<Dynamic>, to:Array<Dynamic>)
	{
		from.remove(object);
		to.unshift(object);
	}
	
	var gc:Array<Dynamic>;
	public function update()
	{
		for (go in active) {
			if (go.kill)
				gc.push(go);
			else if (go.enableUpdate)
				go.update();
			
		}
				
		for (g in gc)
			dispose(g);
			
		if(gc.length >0)
			gc.splice(0, gc.length);
	}
	
	function _create(object:Dynamic)
	{
		var pool_create = Reflect.field(object, "pool_create");
		if (pool_create != null)
			object.pool_create(object);
	}
	
	function _dispose(object:Dynamic)
	{
		var pool_dispose = Reflect.field(object, "pool_dispose");
		if (pool_dispose != null)
			object.pool_dispose(object);
	}
	
	function _recycle(object:Dynamic)
	{
		var pool_recycle = Reflect.field(object, "pool_recycle");
		if (pool_recycle != null)
			object.pool_recycle(object);
	}
	
	public function dispose(object:Dynamic)
	{
		_dispose(object);
		move(object, active, free);
	}
	
	public function get(properties:Dynamic):Dynamic
	{
		if (free.length == 0)
			increasePoolSize(growthRate);
			
		var o:Dynamic = free.pop();
		active.unshift(o);
		
		o.kill = false;
		
		for (fieldName in Reflect.fields(properties))
		{
			Reflect.setProperty(o, fieldName, Reflect.getProperty(properties, fieldName));
		}
		
		_recycle(o);
		
		return o;
	}
	
	public function destroy()
	{
		for (g in active)
		{
			_dispose(g);
			g.destroy();
		}
			
		for (g in free) {
			_dispose(g);
			g.destroy();
		}
		
		free = [];
		active = [];
		gc = [];
	}
	
}