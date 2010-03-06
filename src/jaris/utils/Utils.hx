/**
 * ...
 * @author Jefferson González
 */

package jaris.utils;

/**
 * Some utility functions
 */
class Utils 
{

	/**
	 * Converts degrees to radians for easy rotation where applicable
	 * @param	value A radian value to convert
	 * @return conversion of degree to radian
	 */
	public static function degreesToRadians(value:Float):Float
	{
		return (Math.PI / 180) * value;
	}
	
	/**
	 * Converts a float value representing seconds to a readale string
	 * @param	time A given time in seconds
	 * @return A string in the format 00:00:00
	 */
	public static function formatTime(time:Float):String
	{
		var seconds:String = "";
		var minutes:String = "";
		var hours:String = "";
		var timeString:String = "";
		
		if (((time / 60) / 60) >= 1)
		{
			if (Math.floor((time / 60)) / 60 < 10)
			{
				hours = "0" + Math.floor(time / 60) + ":";
			}
			else
			{
				hours = Math.floor(time / 60) + ":";
			}
			
			if (Math.floor((time / 60) % 60) < 10)
			{
				minutes = "0" + Math.floor((time / 60) % 60) + ":";
			}
			else
			{
				minutes = Math.floor((time / 60) % 60) + ":";
			}
			
			if (Math.floor(time % 60) < 10)
			{
				seconds = "0" + Math.floor(time % 60);
			}
			else
			{
				seconds = Std.string(Math.floor(time % 60));
			}
		}
		else if((time / 60) >= 1)
		{
			hours = "00:";
			
			if (Math.floor(time / 60) < 10)
			{
				minutes = "0" + Math.floor(time / 60) + ":";
			}
			else
			{
				minutes = Math.floor(time / 60) + ":";
			}
			
			if (Math.floor(time % 60) < 10)
			{
				seconds = "0" + Math.floor(time % 60);
			}
			else
			{
				seconds = Std.string(Math.floor(time % 60));
			}
		}
		else
		{
			hours = "00:";
			
			minutes = "00:";
			
			if (Math.floor(time) < 10)
			{
				seconds = "0" + Math.floor(time);
			}
			else
			{
				seconds = Std.string(Math.floor(time));
			}
		}
		
		timeString += hours + minutes + seconds;
		
		return timeString;
	}
	
	/**
	 * Draws a triangle. Im not so good on mathematics so this is incomplete only for play button xD
	 * @param	object
	 * @param	x
	 * @param	y
	 * @param	ratio
	 * @param	rotation
	 */
	public static function drawTriangle(object:Dynamic, x:Float, y:Float, ratio:Float, rotation:Float=0):Void
	{	
		object.graphics.moveTo(x, y);
		object.graphics.lineTo(x, y + ratio);
		object.graphics.lineTo(x + ratio, y + (ratio / 2 ));
		object.graphics.lineTo(x, y);
	}
}