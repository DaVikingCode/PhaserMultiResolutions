package phasermultires.states;

import phasermultires.objects.GameObject;
import phasermultires.objects.GameObjectPool;
import phasermultires.Root;
import phasermultires.utils.MathUtils;
import phaser.core.Group;
import phaser.core.State;
import phaser.gameobjects.Graphics;
import phaser.gameobjects.Sprite;
import phaser.geom.Point;
import phaser.geom.Rectangle;

class MultiResState extends State
{
	static public inline var LETTERBOX = "letterbox";
	static public inline var FULLSCREEN = "fullscreen";

	static public inline var FILL = "fill";
	static public inline var FIT_WIDTH = "fit_width";
	static public inline var FIT_HEIGHT = "fit_height";
	
	static public inline var NONE = "none";
	
	public var root:Root;
	
	//container scaled to the real scaleFactor.
	public var container:Group;
	var containerMask:Graphics;
	
	//helper rect : base game dimensions * scaleFactor
	public var baseRect:Rectangle;
	//helper rect : rectangle pretransformed for container to game positions : stageRect.bottomRight is the game's bottomRight when inside container.
	public var stageRect:Rectangle;
	public var screenRect:Rectangle;
	
	public var ratio:Float;
	public var invratio:Float;
	
	private var letterbox = false;
	
	//aligns container to center
	public var containerAlign = new Point(0.5, 0.5);
	
	var containerFitMode = FULLSCREEN;
	
	public var gameObjects:Array<GameObject>;
	public var gameObjectPools:Array<GameObjectPool>;
	
	public function new() 
	{
		super();
		gameObjects = new Array<GameObject>();
		gameObjectPools = new Array<GameObjectPool>();
		root = Root.instance;
	}
	
	override function preload() {
		super.preload();
		
		baseRect = new Rectangle(0,0,0,0);
		stageRect = new Rectangle(0, 0, 0, 0);
		screenRect = new Rectangle(0, 0, 0, 0);
		
		createHelperRects();
		
		game.scale.onSizeChange.add(_onResize);

		container = add.group();
		
		_onResize();
	}
	
	override function create() {
        super.create();
		game.scale.onSizeChange.add(onResize);
		initialize();
		onResize();
	}
	
	function initialize() {
		
	}
	
	function createHelperRects()
	{
		screenRect.setTo(0, 0, game.width, game.height);
		baseRect.setTo(0, 0, root.base.width * root.scaleFactor , root.base.height * root.scaleFactor);
		
		switch(containerFitMode)
		{
			case FULLSCREEN :
				ratio = root.realScaleFactor;
			case LETTERBOX :
				letterbox = true;
				containerAlign.setTo(0.5, 0.5);
				ratio = root.realScaleFactor;
			case FILL :
				ratio = MathUtils.getFillRatio(root.base, screenRect);
			case FIT_WIDTH :
				ratio = MathUtils.getFitWidthRatio(root.base, screenRect);
			case FIT_HEIGHT :
				ratio = MathUtils.getFitHeightRatio(root.base, screenRect);
			case NONE :
				ratio = 1;
			default:
				ratio = root.realScaleFactor;
				
		}
		
		invratio = 1 / ratio;
		
		var s:Float = root.scaleFactor * invratio;
		
		stageRect.x = - (screenRect.width * containerAlign.x - (root.base.width * ratio) * containerAlign.x) * s ;
		stageRect.y = - (screenRect.height * containerAlign.y - (root.base.height * ratio) * containerAlign.y) * s ;
		stageRect.width = screenRect.width * s;
		stageRect.height = screenRect.height * s;
	}
	
	/**
	 * container setup
	 */
	function _onResize()
	{
		createHelperRects();
		
		container.x = game.width * containerAlign.x - (root.base.width * ratio) * containerAlign.x;
		container.y = game.height * containerAlign.y - (root.base.height * ratio) * containerAlign.y;
		
		container.scale.x = container.scale.y = root.invScaleFactor * ratio;
		
		if (letterbox) //Redraws mask at the right size (masks can't move or scale apparently)
		{
			if (containerMask == null)
			{
				containerMask = new Graphics(game, 0, 0);	
			}
			
			containerMask.clear();
			containerMask.beginFill(0x00FFFF);
			containerMask.drawRect(container.x, container.y,
			baseRect.width * root.invScaleFactor * root.realScaleFactor,
			baseRect.height * root.invScaleFactor * root.realScaleFactor);
			container.mask = containerMask;
		}
	}
	
	/**
	 * calls resize of gameObjects but also to override for positioning.
	 */
	public function onResize()
	{	
		for (g in gameObjects)
			g.resize();
	}
	
	function place(sprite:Sprite, posX:Float = 0, posY:Float = 0)
	{
		if (sprite.parent != container)
			trace("Warning : using place() with a sprite not inside container.");
			
		sprite.x = posX * root.scaleFactor;
		sprite.y = posY * root.scaleFactor;
	}
	
	function placeStage(sprite:Sprite, posX:Float = 0, posY:Float = 0)
	{
		if (sprite.parent != container)
			trace("Warning : using placeStage() with a sprite not inside container.");
			
		sprite.x = stageRect.left +  posX * root.scaleFactor;
		sprite.y = stageRect.top +  posY * root.scaleFactor;
	}
	
	public function getObjectByType(t:Dynamic):GameObject
	{
		for (go in gameObjects)
		{
			if (Std.is(go, t))
				return go;
		}
		
		for (gop in gameObjectPools)
		{
			for (go in gop.active)
				if (Std.is(go, t))
					return cast(go,GameObject);
		}
		
		return null;
	}
	
	public function addGameObject(object:GameObject)
	{
		object.initialize();
		object.kill = false;
		object.initialized = true;
		object.enableUpdate = true;
		gameObjects.push(object);
	}
	
	public function removeGameObject(object:GameObject)
	{
		object.destroy();
		object.initialized = false;
		object.enableUpdate = false;
		gameObjects.remove(object);
	}
	
	public function addGameObjectPool(pool:GameObjectPool)
	{
		gameObjectPools.push(pool);
	}
	
	public function removeGameObjectPool(pool:GameObjectPool)
	{
		pool.destroy();
		gameObjectPools.remove(pool);
	}
	
	var gogc:Array<GameObject> = new Array<GameObject>();
	public var playing:Bool = true;
	
	override function update()
	{
		super.update();

		for (go in gameObjects)
		{
			if(go.enableUpdate)
				go.update();
				
			if (go.kill)
				gogc.push(go);
		}
		
		for (gop in gameObjectPools)
			gop.update();
		
		var go:GameObject;
		while ((go = gogc.pop()) != null)
			removeGameObject(go);
	}
	
	override function shutdown():Void {
		game.scale.onSizeChange.remove(_onResize);
		game.scale.onSizeChange.remove(onResize);
		
		//destroy objects in reverse order so physics are last.
		gameObjects.reverse();
		
		for (go in gameObjects) {
			removeGameObject(go); }
			
		for (gop in gameObjectPools) {
			removeGameObjectPool(gop); }
			
		gameObjectPools = [];
		gameObjects = [];
		gogc = [];
		super.shutdown();
	}
	
}