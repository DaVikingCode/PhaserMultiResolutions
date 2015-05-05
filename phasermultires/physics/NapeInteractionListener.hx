package phasermultires.physics;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.space.Space;
import phasermultires.objects.PhysicsGameObject;

class NapeInteractionListener
{
	var _space:Space;
	var _enabled:Bool = false;
	var _beginInteractionListener:InteractionListener;
	var _endInteractionListener:InteractionListener;
		
	public function new(space:Space) 
	{
		_space = space;
		
		_beginInteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onInteractionBegin);
		_endInteractionListener = new InteractionListener(CbEvent.END, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onInteractionEnd); 
	
		set_enabled(true);
	}
	
	public function destroy():Void {
			
			_space.listeners.clear();
	}
	
	public function onInteractionBegin(interactionCallback:InteractionCallback):Void {
			
			var a:PhysicsGameObject = interactionCallback.int1.userData.myData;
			var b:PhysicsGameObject = interactionCallback.int2.userData.myData;
			
			if (a == null || b == null)
				return;
			
			a.onBeginContact(interactionCallback);
			b.onBeginContact(interactionCallback);
		}
		
		public function onInteractionEnd(interactionCallback:InteractionCallback):Void {
			
			var a:PhysicsGameObject = interactionCallback.int1.userData.myData;
			var b:PhysicsGameObject = interactionCallback.int2.userData.myData;
			
			if (a == null || b == null)
				return;
				
			a.onEndContact(interactionCallback);
			b.onEndContact(interactionCallback);
		}
		
		public function set_enabled(value:Bool):Void {
			
			if (_enabled == value)
				return;
				
			_enabled = value;
				
			if(_enabled) {
				_space.listeners.add(_beginInteractionListener);
				_space.listeners.add(_endInteractionListener);
			} else {
				_space.listeners.remove(_beginInteractionListener);
				_space.listeners.remove(_endInteractionListener);
			}
		}
		
		public function get_enabled():Bool {
			return _enabled;
		}
	
}