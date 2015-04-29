package dvkgc.phaser.objects;
import dvkgc.phaser.Root;
import dvkgc.phaser.states.MultiResState;
import phaser.core.Game;
import phaser.core.Group;
import phaser.geom.Rectangle;

/**
 * This is more of a structure to help with MultiResState.
 * You manage positions and so on, yourself.
 */
class GameObject
{
	private var root:Root;
	private var game:Game;
	private var state:MultiResState;
	private var group:Group;
	
	//x and y only use to set things up;
	@:isVar public var x(get, set):Float;
	@:isVar public var y(get, set):Float;
	@:isVar public var width(get, set):Float;
	@:isVar public var height(get, set):Float;
	
	public var initialized:Bool = false;
	public var enableUpdate:Bool = false;
	public var kill:Bool = false; //much like CE, setting to true will remove the GameObject from MultiResState and call destroy
	public var cacheBounds:Rectangle;
	
	public function new(?group:Group = null) 
	{
		x = y = width = height = 0;
		
		root = Root.instance;
		game = root.game;
		state = root.getCurrentMultiResState();
		this.group = group != null? group : state.container;
		cacheBounds = new Rectangle(0, 0, 0, 0);
	}
	
	//initialize is called when added to the state
	public function initialize() { }
	
	//update is called by MultiResState whenn added. enableUpdate is set to true then.
	public function update() { }
	
	public function resize() {}
	
	public function destroy() { }
	
	public function get_x() {
		return x;
	 }

	public function set_x(x) {
		return this.x = x;
	}
	
	public function get_y() {
		return y;
	 }

	public function set_y(y) {
		return this.y = y;
	}
	
	public function get_width() {
		return width;
	 }

	public function set_width(width) {
		return this.width = width;
	}
	
	public function get_height() {
		return height;
	 }

	public function set_height(height) {
		return this.height = height;
	}
	
}