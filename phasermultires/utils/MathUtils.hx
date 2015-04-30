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
}