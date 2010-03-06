/**
 * ...
 * @author Jefferson González
 */

package jaris.animation;

/**
 * Gives quick access usage to jaris effects
 */
class Animation
{

	/**
	 * Quick access to fade in effect
	 * @param	object
	 * @param	seconds
	 */
	public static function fadeIn(object:Dynamic, seconds:Float)
	{
		var animation:AnimationsBase = new AnimationsBase();
		animation.fadeIn(object, seconds);
	}
	
	/**
	 * Quick access to fade out effect
	 * @param	object
	 * @param	seconds
	 */
	public static function fadeOut(object:Dynamic, seconds:Float)
	{
		var animation:AnimationsBase = new AnimationsBase();
		animation.fadeOut(object, seconds);
	}
	
	/**
	 * Quick access to slide in effect
	 * @param	object
	 * @param	position
	 * @param	seconds
	 */
	public static function slideIn(object:Dynamic, position:String, seconds:Float)
	{
		var animation:AnimationsBase = new AnimationsBase();
		animation.slideIn(object, position, seconds);
	}
	
	/**
	 * Quick access to slide out effect
	 * @param	object
	 * @param	position
	 * @param	seconds
	 */
	public static function slideOut(object:Dynamic, position:String, seconds:Float)
	{
		var animation:AnimationsBase = new AnimationsBase();
		animation.slideOut(object, position, seconds);
	}
	
}