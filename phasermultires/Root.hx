package phasermultires;

import phasermultires.states.MultiResState;
import js.Browser;
import phaser.core.Game;
import phaser.core.ScaleManager;
import phaser.geom.Rectangle;
import phaser.Phaser;

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
	
	public var pageAlignHorizontally = true;
	public var pageAlignVertically = true;
	public var canExpandParent = false;
	public var forceOrientation = ORIENTATION_NONE;
	public var useDevicePixelRatio = true;

    public function new() {
		
		instance = this;
		
		var userAgentReg = new EReg("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini","i");
		isMobile = userAgentReg.match(Browser.navigator.userAgent);
		
		isCocoon = Reflect.hasField(Browser.navigator, 'isCocoonJS') ? true : false;
		
		setupConfig();
        
		game = new Game( 
		{ width:this.width,
		height:this.height,
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

		if (isDesktop)
		{
			game.scale.scaleMode = ScaleManager.RESIZE;
		}
		else
		{
			game.scale.scaleMode = isCocoon ? ScaleManager.USER_SCALE : ScaleManager.RESIZE;

			game.scale.pageAlignHorizontally = pageAlignHorizontally;
			game.scale.pageAlignVertically = pageAlignVertically;
			
			game.scale.compatibility.canExpandParent = canExpandParent;
			
			if(forceOrientation != ORIENTATION_NONE) {
				game.scale.forceOrientation( forceOrientation == ORIENTATION_BOTH? true :  forceOrientation == ORIENTATION_LANDSCAPE ,  forceOrientation == ORIENTATION_BOTH? true :  forceOrientation == ORIENTATION_PORTRAIT );
			}
			
			game.scale.enterIncorrectOrientation.add(onEnterIncorrectOrientation);
			game.scale.leaveIncorrectOrientation.add(onLeaveIncorrectOrientation);
			game.scale.onOrientationChange.add(onOrientationChange);

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
		if (game.height / game.width > base.height / base.width)
			return game.width / base.width;
		else
			return game.height / base.height;
	}
	
	function resetScales()
	{
		realScaleFactor = getRatio();
		invRealScaleFactor = 1 / realScaleFactor;
		
		if (firstTimeResizeDone) //ScaleFactor is calculated once.
			return;
		
		scaleFactor = findScaleFactor(scales, getRatio() * (useDevicePixelRatio?game.device.pixelRatio:1) );
		invScaleFactor = 1 / scaleFactor;
		
		if(enableDebug)
			trace("[Root] ScaleFactor: " + scaleFactor + " using device pixel ratio: " + useDevicePixelRatio + " " + width + " " + height);
	}
	
	function onResize()
	{
		resetScales();
	}
	
	/**
	 * if you override create, it's important you call super.create();
	 */
    function create() {
		firstTimeResizeDone = true;
		initialize();
    }
	
	function preload()
	{
		
	}
	
	function initialize()
	{
		
	}
	
	public function getCurrentMultiResState():MultiResState { if (game.state.getCurrentState() != null) return cast(game.state.getCurrentState(), MultiResState); else return null; }
}
