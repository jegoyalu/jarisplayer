/**
 * ...
 * @author Jefferson González
 */

package jaris.events;

import flash.net.NetStream;

/**
 * Stores constants of the player events
 */
class PlayerEvents 
{
	public static var ASPECT_RATIO = "onAspectRatio";
	public static var MOUSE_SHOW = "onMouseShow";
	public static var MOUSE_HIDE = "onMouseHide";
	public static var FULLSCREEN = "onFullscreen";
	public static var VOLUME_UP = "onVolumeUp";
	public static var VOLUME_DOWN = "onVolumeDown";
	public static var MUTE = "onMute";
	public static var FORWARD = "onForward";
	public static var REWIND = "onRewind";
	public static var PLAY_PAUSE = "onPlayPause";
	public static var BUFFERING = "onBuffering";
	public static var NOT_BUFFERING = "onNotBuffering";
	public static var CONNECTION_FAILED = "onConnectionFailed";
	public static var CONNECTION_SUCCESS = "onConnectionSuccess";
	public static var META_RECIEVED = "onMetaDataReceived";
	public static var PLAYBACK_FINISHED = "onPlaybackFinished";
	public static var STOP_CLOSE = "onStopAndClose";
	public static var RESIZE = "onResize";
	
	public var aspectRatio:Float;
	public var fullscreen:Bool;
	public var mute:Bool;
	public var volume:Float;
	public var duration:Float;
	public var width:Float;
	public var height:Float;
	public var stream:NetStream;
	public var time:Float;
	
	
	public function new() 
	{
		fullscreen = false;
		mute = false;
		volume = 1.0;
		duration = 0;
		width = 0;
		height = 0;
		time = 0;
	}
	
}