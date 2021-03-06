package phasermultires.utils;
import phaser.geom.Rectangle;

class MathUtils
{
	public static var r1:Rectangle = new Rectangle(0, 0, 0, 0);
	public static var r2:Rectangle = new Rectangle(0, 0, 0, 0);
	
	public static function randomInt(min:Int, max:Int):Int
	{
			return Math.floor(Math.random() * (1 + max - min)) + min;
	}
	
	public static function randomFloat(min:Float, max:Float):Float
	{
			return min + (max - min) * Math.random();
	}
		
	public static function bestFitRatio(rect:Rectangle, into:Rectangle):Float
	{
		if (into.height / into.width > rect.height / rect.width)
				return into.width / rect.width;
			else
				return into.height / rect.height;
	}
	
	public static function getFillRatio(rect:Rectangle, into:Rectangle):Float
	{
		if (into.height / into.width > rect.height / rect.width)
			return into.height / rect.height;
		else
			return into.width / rect.width;
	}
		
		
	public static function getFitHeightRatio(fit:Rectangle,inside:Rectangle,scale:Float = 1):Float 
	{
		return (inside.height / fit.height)*scale;
	}
		

	public static function getFitWidthRatio(fit:Rectangle,inside:Rectangle,scale:Float = 1):Float 
	{
		return (inside.width / fit.width)*scale;
	}
	
	/**
	 * Point in polygon test
	 * https://github.com/underscorediscovery/nme-haxe-pnpoly
	 * @param	pt point to test for
	 * @param	pos translation of polygon
	 * @param	verts local vertices of polygon
	 * @return
	 */
	public static function pnpoly(pt:Dynamic, pos:Dynamic, verts:Array<Dynamic>) : Bool {
		var c : Bool = false;
		var nvert : Int = verts.length;
		var j : Int = nvert - 1;

		for(i in 0 ... nvert) {            
			
			if ((( (verts[i].y+pos.y) > pt.y) != ((verts[j].y+pos.y) > pt.y)) &&
			   (pt.x < ( (verts[j].x+pos.x) - (verts[i].x+pos.x)) * (pt.y - (verts[i].y+pos.y)) / ( (verts[j].y+pos.y) - (verts[i].y+pos.y)) + (verts[i].x+pos.x)) ) {
				c = !c;
			}

			j = i;
		}

		return c;
	}
	
	
	
	/**
	 * Helper to get world bounds of object
	 * @param	object (sprite,group...)
	 * @return phaser Rectangle
	 */
	public static function getWorldBounds(object:Dynamic,?rect:Rectangle = null):Rectangle
	{
		var tx:Float = object.x;
		var ty:Float = object.y;
		var w:Float = object.width;
		var h:Float = object.height;
		
		if(object.pivot) {
			tx -= object.pivot.x;
			ty -= object.pivot.y;
		}
			
		if(object.anchor) {
			tx -= object.anchor.x * object.width;
			ty -= object.anchor.y * object.height;
		}
		
		while ((object = object.parent) != null) {
			
			untyped object.updateTransform(); //force update transform
			
			tx *= object.scale.x;
			ty *= object.scale.y;
			w  *= object.scale.x;
			h  *= object.scale.y;
			
			tx += object.x;
			ty += object.y;
			
			if(object.pivot) {
				tx -= object.pivot.x;
				ty -= object.pivot.y;
			}
			
			if(object.anchor) {
				tx -= object.anchor.x * object.width;
				ty -= object.anchor.y * object.height;
			}
		}
		
		if (rect == null)
			rect = new Rectangle(tx, ty, w, h);
		else
			rect.setTo(tx, ty, w, h);
			
		return rect;
	}
}