package phasermultires;

import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.Element;
import phaser.core.Game;
import phaser.core.ScaleManager;
import phaser.geom.Rectangle;
import phaser.Phaser;
import phasermultires.states.MultiResState;
import phasermultires.utils.MathUtils;

/**
 * Root class for phaser resolution idependent games by Da Viking Code
 */
class Root {
	
	static public inline var ORIENTATION_PORTRAIT = "portrait";
	static public inline var ORIENTATION_LANDSCAPE = "landscape";
	static public inline var ORIENTATION_BOTH = "both";
	static public inline var ORIENTATION_NONE = "none";
	
	static public var instance:Root;

    public var game:Game;
	public var userData:Dynamic;
	
    public var base = new Rectangle(0,0,800,600);
	public var scales:Array<Float> = [1];
	
	public var scaleFactor:Float = 1;
	public var invScaleFactor:Float = 1;
	
	public var invRealScaleFactor:Float = 1;
	public var realScaleFactor:Float = 1;
	
	private var firstTimeResizeDone = false;
	
	public var isCocoon:Bool;
	public var isMobile:Bool;
	public var isDesktop:Bool;
	
	var width:Dynamic = "100%";
	var height:Dynamic = "100%";
	var renderer:Int = Phaser.AUTO;
	var parent:String = "game";
	var resolution:Float = 1;
	var transparent:Bool = false;
	var antialias:Bool = true;
	var enableDebug:Bool = true;
	var scaleMode:Int = ScaleManager.SHOW_ALL;
	
	var element:Element;
	public var elementStyle:CSSStyleDeclaration;
	
	public var pageAlignHorizontally = true;
	public var pageAlignVertically = true;
	public var canExpandParent = false;
	public var forceOrientation = ORIENTATION_NONE;
	public var useDevicePixelRatio = true;
	
	public var stageWidth:Float = 800;
	public var stageHeight:Float = 600;
	
	public var screenWidth:Float = 800;
	public var screenHeight:Float = 600;
	public var stageRatio:Float = 1;
	
	public var currentState:MultiResState;

    public function new() {
		
		instance = this;
		
		var userAgentReg = new EReg("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini","i");
		isMobile = userAgentReg.match(Browser.navigator.userAgent);
		
		isCocoon = Reflect.hasField(Browser.navigator, 'isCocoonJS') ? true : false;
		
		setupConfig();
		
		element = Browser.window.document.getElementById(parent);
		elementStyle = Browser.window.getComputedStyle(element);
		
		if(useDevicePixelRatio)
			resolution = Browser.window.devicePixelRatio;
			
		
		var w:Float =  Std.parseFloat(elementStyle.width.split("p")[0]) * resolution;
		var h:Float =  Std.parseFloat(elementStyle.height.split("p")[0]) * resolution;
		
		if (forceOrientation == Root.ORIENTATION_LANDSCAPE && h > w) { var t = w; w = h; h = t; }
		
		var r = MathUtils.bestFitRatio(base, new Rectangle(0, 0, w, h));
		
		game = new Game( 
		{ width:base.width * r,
		height:base.height * r,
		resolution:this.resolution,
		renderer:this.renderer,
		parent:this.parent,
		transparent:this.transparent,
		antialias:this.antialias,
		enableDebug:this.enableDebug,
		state: { create:create, preload:preload, init:init }} );
    }
	
	//override and change config here, called before game is created.
	function setupConfig() {}
	
	public function findScaleFactor(assetSizes:Array<Float>, ratio:Float = 1):Float
	{
		var arr:Array<Float> = assetSizes;
		arr.sort(function(a:Float,b:Float):Int {
		if (a == b)
			return 0;
		if (a > b)
			return 1;
		else
			return -1;
		});
		
		var scaleF:Float = Math.floor(ratio * 1000) / 1000;
		var closest:Float = -1;
		var f:Float;
		
		for (f in arr)
			if (closest == -1 || Math.abs(f - scaleF) < Math.abs(closest - scaleF))
				closest = f;
			
		return closest;
	}
	
	/**
	 * Resets scaleFactor. Can be done to force loading other sets of textures, don't call in the middle of a state.
	 * @param	waitForNextResize
	 */
	public function resetScaleFactor(waitForNextResize:Bool = false)
	{
		firstTimeResizeDone = false;
		
		if (!waitForNextResize)
			onResize();
	}
	
	function init()
	{	
		isDesktop = game.device.desktop;
		stageRatio = game.device.pixelRatio;

		if (isDesktop)
		{
			game.scale.scaleMode = scaleMode;
			
			game.scale.pageAlignHorizontally = pageAlignHorizontally;
			game.scale.pageAlignVertically = pageAlignVertically;
			
			game.scale.onSizeChange.add(onResize); 
			
		}
		else
		{
			game.scale.scaleMode = isCocoon ? ScaleManager.USER_SCALE : scaleMode;

			game.scale.pageAlignHorizontally = pageAlignHorizontally;
			game.scale.pageAlignVertically = pageAlignVertically;
			
			game.scale.compatibility.canExpandParent = canExpandParent;

			game.scale.onSizeChange.add(onResize); 
		
		}

		game.scale.setResizeCallback(onResize, this);
		resetScales();
	}
	
	function onEnterIncorrectOrientation(){}
	function onLeaveIncorrectOrientation(){}
	function onOrientationChange(){}
	
	function getRatio():Float
	{
		if (stageHeight /stageWidth > base.height / base.width)
			return stageWidth / base.width;
		else
			return stageHeight / base.height;
	}
	
	var lastOrientationIncorrect:Bool = false;
	var lastOrientation = Root.ORIENTATION_NONE;
	var currentOrientation = Root.ORIENTATION_NONE;
	function orientationTest()
	{	
		currentOrientation = screenWidth > screenHeight ? Root.ORIENTATION_LANDSCAPE : Root.ORIENTATION_PORTRAIT;
		
		if (currentOrientation != lastOrientation)
			onOrientationChange();
		
		if (lastOrientationIncorrect && currentOrientation == forceOrientation)
			onLeaveIncorrectOrientation();
		else if (
		(forceOrientation == Root.ORIENTATION_LANDSCAPE && currentOrientation != Root.ORIENTATION_LANDSCAPE) 
		|| 
		(forceOrientation == Root.ORIENTATION_PORTRAIT && currentOrientation != Root.ORIENTATION_PORTRAIT)
		) {
			lastOrientationIncorrect = true;
			onEnterIncorrectOrientation();
		}
		
		lastOrientation = currentOrientation;
		
	}
	
	function resetScales()
	{
		realScaleFactor = getRatio();
		invRealScaleFactor = 1 / realScaleFactor;
		
		elementStyle = Browser.window.getComputedStyle(element);
		
		screenWidth =  Std.parseFloat(elementStyle.width.split("p")[0]) * (useDevicePixelRatio ? Browser.window.devicePixelRatio : 1);
		screenHeight =  Std.parseFloat(elementStyle.height.split("p")[0]) * (useDevicePixelRatio ? Browser.window.devicePixelRatio : 1);
		
		stageWidth = game.width;
		stageHeight = game.height;
		
		if (firstTimeResizeDone) //ScaleFactor is calculated once.
			return;
			
		scaleFactor = findScaleFactor(scales, getRatio() );
		invScaleFactor = 1 / scaleFactor;
		
	}
	
	function onResize()
	{
		resetScales();
		orientationTest();
	}
	
	/**
	 * if you override create, it's important you call super.create();
	 */
    function create() {
		firstTimeResizeDone = true;
		initialize();
		orientationTest();
    }
	
	function preload()
	{
		
	}
	
	function initialize()
	{
		
	}
	
}
