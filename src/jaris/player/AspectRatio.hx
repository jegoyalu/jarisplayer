/**
 * ...
 * @author Jefferson González
 */

package jaris.player;

/**
 * Stores the player used constants
 */
class AspectRatio 
{
	public static var _1_1:Float = 1 / 1;	
	public static var _3_2:Float = 3 / 2;	
	public static var _4_3:Float = 4 / 3;
	public static var _5_4:Float = 5 / 4;
	public static var _14_9:Float = 14 / 9;
	public static var _14_10:Float = 14 / 10;
	public static var _16_9:Float = 16 / 9;
	public static var _16_10:Float = 16 / 10;
	
	/**
	 * Calculates the ratio for a given width and height
	 * @param	width
	 * @param	height
	 * @return aspect ratio
	 */
	public static function getAspectRatio(width:Float, height:Float):Float
	{
		return width / height;
	}
}