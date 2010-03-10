/**    
 * @author Jefferson González
 * @copyright 2010 Jefferson González
 *
 * @license 
 * This file is part of Jaris FLV Player.
 *
 * Jaris FLV Player is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License or GNU LESSER GENERAL 
 * PUBLIC LICENSE as published by the Free Software Foundation, either version 
 * 3 of the License, or (at your option) any later version.
 *
 * Jaris FLV Player is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License and 
 * GNU LESSER GENERAL PUBLIC LICENSE along with Jaris FLV Player.  If not, 
 * see <http://www.gnu.org/licenses/>.
 */

package jaris.player;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.FullScreenEvent;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import flash.utils.Timer;
import jaris.display.Poster;
import jaris.events.PlayerEvents;

/**
 * Jaris main video player
 */
class Player extends EventDispatcher
{
	//{Member variables
	private var _stage:Stage;
	private var _movieClip:MovieClip;
	private var _connection:NetConnection;
	private var _stream:NetStream;
	private var _fullscreen:Bool;
	private var _soundMuted:Bool;
	private var _volume:Float;
	private var _mouseVisible:Bool;
	private var _mediaLoaded:Bool;
	private var _hideMouseTimer:Timer;
	private var _checkAudioTimer:Timer;
	private var _mediaSource:String;
	private var _type:String;
	private var _streamType:String;
	private var _server:String; //For future use on rtmp
	private var _sound:Sound;
	private var _soundChannel:SoundChannel;
	private var _video:Video;
	private var _videoWidth:Float;
	private var _videoHeight:Float;
	private var _videoMask:Sprite;
	private var _videoQualityHigh:Bool;
	private var _mediaDuration:Float;
	private var _isPlaying:Bool;
	private var _aspectRatio:Float;
	private var _originalAspectRatio:Float;
	private var _mediaEndReached:Bool;
	private var _seekPoints:Array<Float>;
	private var _downloadCompleted:Bool;
	private var _startTime:Float;
	private var _firstLoad:Bool;
	private var _stopped:Bool;
	private var _useHardWareScaling:Bool;
	private var _poster:Poster;
	//}
	
	
	//{Constructor
	public function new() 
	{
		super();
		
		//{Main Variables Init
		_stage = Lib.current.stage;
		_movieClip = Lib.current;
		_mouseVisible = true;
		_soundMuted = false;
		_volume = 1.0;
		_fullscreen = false;
		_mediaLoaded = false;
		_hideMouseTimer = new Timer(1500);
		_checkAudioTimer = new Timer(100);
		_seekPoints = new Array();
		_downloadCompleted = false;
		_startTime = 0;
		_firstLoad = true;
		_stopped = false;
		_videoQualityHigh = false;
		_isPlaying = false;
		_streamType = StreamType.FILE;
		_type = InputType.VIDEO;
		_server = "";
		//}
		
		//{Initialize sound object
		_sound = new Sound();
		_sound.addEventListener(Event.COMPLETE, onSoundComplete);
        _sound.addEventListener(Event.ID3, onSoundID3);
        _sound.addEventListener(IOErrorEvent.IO_ERROR, onSoundIOError);
        _sound.addEventListener(ProgressEvent.PROGRESS, onSoundProgress);

		//}
		
		//{Initialize video and connection objets
		_connection = new NetConnection();
		_connection.connect(null);
		_stream = new NetStream(_connection);
		
		_video = new Video(_stage.stageWidth, _stage.stageHeight);
		_video.attachNetStream(_stream);
		
		_movieClip.addChild(_video);
		//}
		
		//Video mask so that custom menu items work
		_videoMask = new Sprite();
		_movieClip.addChild(_videoMask);
		
		//Set initial rendering to high quality
		toggleQuality();
		
		//{Initialize system event listeners
		_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		_stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
		_stage.addEventListener(Event.RESIZE, onResize);
		_hideMouseTimer.addEventListener(TimerEvent.TIMER, hideMouseTimer);
		_checkAudioTimer.addEventListener(TimerEvent.TIMER, checkAudioTimer);
		_stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		//}
	}
	//}
	
	
	//{Timers
	/**
	 * Timer that hides the mouse pointer when it is idle and dispatch the PlayerEvents.MOUSE_HIDE
	 * @param	event
	 */
	private function hideMouseTimer(event:TimerEvent):Void
	{
		if (_fullscreen)
		{
			if (_mouseVisible)
			{
				_mouseVisible = false;
			}
			else
			{
				Mouse.hide();
				callEvents(PlayerEvents.MOUSE_HIDE);
				_hideMouseTimer.stop();
			}
		}
	}
	
	/**
	 * To check if the sound finished playing
	 * @param	event
	 */
	private function checkAudioTimer(event:TimerEvent):Void
	{
		if (_soundChannel.position + 100 >= _sound.length)
		{
			_isPlaying = false;
			_mediaEndReached = true;
			callEvents(PlayerEvents.PLAYBACK_FINISHED);
			
			_checkAudioTimer.stop();
		}
	}
	//}
	
	
	//{Events
	/**
	 * Checks if connection failed or succeed
	 * @param	event
	 */
	private function onNetStatus(event:NetStatusEvent):Void
	{
		switch (event.info.code)
		{
			case "NetConnection.Connect.Success":
				callEvents(PlayerEvents.CONNECTION_SUCCESS);

			case "NetStream.Play.StreamNotFound":
				trace("Stream not found: " + _mediaSource);
				callEvents(PlayerEvents.CONNECTION_FAILED);
				
			case "NetStream.Play.Stop":
				if (_isPlaying) { _stream.togglePause(); }
				_isPlaying = false;
				_mediaEndReached = true;
				callEvents(PlayerEvents.PLAYBACK_FINISHED);
				
			case "NetStream.Play.Start":
				_isPlaying = true;
				_mediaEndReached = false;
				if (_stream.bytesLoaded != _stream.bytesTotal)
				{
					callEvents(PlayerEvents.BUFFERING);
				}
				
			case "NetStream.Seek.Notify":
				_mediaEndReached = false;
				
			case "NetStream.Buffer.Empty":
				if (_stream.bytesLoaded != _stream.bytesTotal)
				{
					callEvents(PlayerEvents.BUFFERING);
				}
				
			case "NetStream.Buffer.Full":
				callEvents(PlayerEvents.NOT_BUFFERING);
				
			case "NetStream.Buffer.Flush":
				if (_stream.bytesLoaded == _stream.bytesTotal)
				{
					_downloadCompleted = true;
				}
		}
	}
	
	/**
	 * Proccess keyboard shortcuts
	 * @param	event
	 */
	private function onKeyDown(event:KeyboardEvent):Void
	{
		var F_KEY:UInt = 70;
		var M_KEY:UInt = 77;
		var X_KEY:UInt = 88;
		
		switch(event.keyCode)
		{
			case Keyboard.TAB:
				toggleAspectRatio();
				callEvents(PlayerEvents.ASPECT_RATIO);
			
			case F_KEY:
				toggleFullscreen();
				
			case M_KEY:
				toggleMute();
				callEvents(PlayerEvents.MUTE);
				
			case Keyboard.UP:
				volumeUp();
				callEvents(PlayerEvents.VOLUME_UP);
				
			case Keyboard.DOWN:
				volumeDown();
				callEvents(PlayerEvents.VOLUME_DOWN);
				
			case Keyboard.RIGHT:
				forward();
				callEvents(PlayerEvents.FORWARD);
				
			case Keyboard.LEFT:
				rewind();
				callEvents(PlayerEvents.REWIND);
				
			case Keyboard.SPACE:
				togglePlay();
				callEvents(PlayerEvents.PLAY_PAUSE);
				
			case X_KEY:
				stopAndClose();
				callEvents(PlayerEvents.STOP_CLOSE);
		}
	}
	
	/**
	 * IF player is full screen shows the mouse when gets hide
	 * @param	event
	 */
	private function onMouseMove(event:MouseEvent):Void
	{
		if (_fullscreen && !_mouseVisible)
		{
			if (!_hideMouseTimer.running)
			{
				_hideMouseTimer.start();
			}
			
			_mouseVisible = true;
			Mouse.show();
			
			callEvents(PlayerEvents.MOUSE_SHOW);
		}
	}
	
	/**
	 * Resize video player
	 * @param	event
	 */
	private function onResize(event:Event):Void
	{
		resizeAndCenterPlayer();
	}
	
	/**
	 * Dispath a full screen event to listeners as redraw player an takes care of some other aspects
	 * @param	event
	 */
	private function onFullScreen(event:FullScreenEvent):Void
	{
		_fullscreen = event.fullScreen;
		
		if (!event.fullScreen)
		{
			Mouse.show();
			callEvents(PlayerEvents.MOUSE_SHOW);
			_mouseVisible = true;
		}
		else
		{
			_mouseVisible = true;
			_hideMouseTimer.start();
			
			//If browser player resume playing
			if ((Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn"))
			{
				togglePlay();
			}
		}
		
		resizeAndCenterPlayer();
		
		callEvents(PlayerEvents.FULLSCREEN);
	}
	
	/**
	 * Sits for any cue points available
	 * @param	data
	 * @note Planned future implementation
	 */
	private function onCuePoint(data:Dynamic):Void
	{
		
	}
	
	/**
	 * After a video is loaded this callback gets the video information at start and stores it on variables
	 * @param	data
	 */
	private function onMetaData(data:Dynamic):Void
	{
		if (_firstLoad)
		{
			_isPlaying = true;
			
			if (_poster != null)
			{
				_poster.visible = false;
			}
			
			_firstLoad = false;
			if (data.width)
			{
				_videoWidth = data.width;
				_videoHeight = data.height;
			}
			else
			{
				_videoWidth = _video.width;
				_videoHeight = _video.height;
			}
			
			//Store seekpoints times
			if (data.hasOwnProperty("seekpoints")) //MP4
			{
				for (position in Reflect.fields(data.seekpoints))
				{
					_seekPoints.push(Reflect.field(data.seekpoints, position).time);
				}
			}
			else if (data.hasOwnProperty("keyframes")) //FLV
			{
				for (position in Reflect.fields(data.keyframes.times))
				{
					_seekPoints.push(Reflect.field(data.keyframes.times, position));
				}
			}
			
			_mediaLoaded = true;
			_mediaDuration = data.duration;
			_aspectRatio = AspectRatio.getAspectRatio(_videoWidth, _videoHeight);
			_originalAspectRatio = _aspectRatio;
			
			callEvents(PlayerEvents.MEDIA_INITIALIZED);
			
			resizeAndCenterPlayer();
		}
	}
	
	/**
	 * Dummy function invoked for pseudostream servers
	 * @param	data
	 */
	private function onLastSecond(data:Dynamic):Void
	{
		//To work on it?
	}
	
	/**
	 * When sound finished downloading
	 * @param	event
	 */
	private function onSoundComplete(event:Event)
	{
		_mediaDuration = _sound.length / 1000;
		_downloadCompleted = true;
		
		callEvents(PlayerEvents.MEDIA_INITIALIZED);
	}
	
	/**
	 * Mimic stream onMetaData
	 * @param	event
	 */
	private function onSoundID3(event:Event)
	{
		if (_firstLoad)
		{
			_soundChannel = _sound.play();
			_checkAudioTimer.start();

			_isPlaying = true;
			
			if (_poster != null)
			{
				_videoWidth = _poster.width;
				_videoHeight = _poster.height;
			}
			
			_firstLoad = false;
			
			_mediaLoaded = true;
			_mediaDuration = ((_sound.bytesTotal / _sound.bytesLoaded) * _sound.length) / 1000;
			_aspectRatio = AspectRatio.getAspectRatio(_videoWidth, _videoHeight);
			_originalAspectRatio = _aspectRatio;
			
			callEvents(PlayerEvents.CONNECTION_SUCCESS);
			callEvents(PlayerEvents.MEDIA_INITIALIZED);
			
			resizeAndCenterPlayer();
		}
	}
	
	/**
	 * Dispatch connection failed event on error
	 * @param	event
	 */
	private function onSoundIOError(event:IOErrorEvent)
	{
		callEvents(PlayerEvents.CONNECTION_FAILED);
	}
	
	/**
	 * Monitor sound download progress
	 * @param	event
	 */
	private function onSoundProgress(event:ProgressEvent)
	{
		if (_sound.isBuffering)
		{
			callEvents(PlayerEvents.BUFFERING);
		}
		else
		{
			callEvents(PlayerEvents.NOT_BUFFERING);
		}
		
		_mediaDuration = ((_sound.bytesTotal / _sound.bytesLoaded) * _sound.length) / 1000;
		callEvents(PlayerEvents.MEDIA_INITIALIZED);
	}
	//}
	
	
	//{Private Methods
	/**
	 * Function used each time is needed to dispatch an event
	 * @param	type
	 */
	private function callEvents(type:String):Void
	{
		var playerEvent:PlayerEvents = new PlayerEvents(type, true);
		
		playerEvent.aspectRatio = getAspectRatio();
		playerEvent.duration = getDuration();
		playerEvent.fullscreen = isFullscreen();
		playerEvent.mute = getMute();
		playerEvent.volume = getVolume();
		playerEvent.width = _video.width;
		playerEvent.height = _video.height;
		playerEvent.stream = getNetStream();
		playerEvent.sound = getSound();
		playerEvent.time = getCurrentTime();
		
		dispatchEvent(playerEvent);
	}
	
	/**
	 * Reposition and resizes the video player to fit on screen
	 */
	private function resizeAndCenterPlayer():Void
	{
		_video.height = _stage.stageHeight;
		_video.width = _video.height * _aspectRatio;
		
		_video.x = (_stage.stageWidth / 2) - (_video.width / 2);
		
		_videoMask.graphics.clear();
		_videoMask.graphics.lineStyle();
		_videoMask.graphics.beginFill(0x000000, 0);
		_videoMask.graphics.drawRect(_video.x, _video.y, _video.width, _video.height);
		_videoMask.graphics.endFill();
		
		callEvents(PlayerEvents.RESIZE);
	}
	
	/**
	 * Check the best seek point available if the seekpoints array is available
	 * @param	time time in seconds
	 * @return best seek point in seconds or given one if no seekpoints array is available
	 */
	private function getBestSeekPoint(time:Float):Float
	{
		if (_seekPoints.length > 0)
		{
			var timeOne:String="0";
			var timeTwo:String="0";
			
			for(prop in Reflect.fields(_seekPoints))
			{
				if(Reflect.field(_seekPoints,prop) < time)
				{
					timeOne = prop;
				}
				else
				{
					timeTwo = prop;
				break;
				}
			}

			if(time - _seekPoints[Std.parseInt(timeOne)] < _seekPoints[Std.parseInt(timeTwo)] - time)
			{
				return _seekPoints[Std.parseInt(timeOne)];
			}
			else
			{
				return _seekPoints[Std.parseInt(timeTwo)];
			}
		}
		
		return time;
	}
	
	/**
	 * Checks if the given seek time is already buffered
	 * @param	time time in seconds
	 * @return true if can seek false if not in buffer
	 */
	private function canSeek(time:Float):Bool
	{
		if (_type == InputType.VIDEO)
		{
			time = getBestSeekPoint(time);
		}
		
		var cacheTotal = Math.floor((getDuration() - _startTime) * (getBytesLoaded() / getBytesTotal())) - 1;

		if(time >= _startTime && time < _startTime + cacheTotal)
		{
			return true;
		}
		
		return false;
	}
	//}
	
	
	//{Public methods	
	/**
	 * Loads a video and starts playing it
	 * @param	video video url to load
	 */
	public function load(source:String, type:String="video", streamType:String="file", server:String=""):Void
	{
		_type = type;
		_streamType = streamType;
		_mediaSource = source;
		_stopped = false;
		_mediaLoaded = false;
		_firstLoad = true;
		_startTime = 0;
		_downloadCompleted = false;
		_seekPoints = new Array();
		_server = server;
		
		callEvents(PlayerEvents.BUFFERING);
		
		if (_type == InputType.VIDEO)
		{	
			_stream.bufferTime = 10;
			_stream.play(source);
			_stream.client = this;
		}
		else if(_type == InputType.AUDIO && _streamType == StreamType.FILE)
		{
			_sound.load(new URLRequest(source));
		}
	}
	
	/**
	 * Closes the connection and makes player available for another video
	 */
	public function stopAndClose():Void
	{
		_mediaLoaded = false;
		_isPlaying = false;
		_stopped = true;
		_startTime = 0;
		_poster.visible = true;
		
		if (_type == InputType.VIDEO)
		{
			_stream.close();
		}
		else
		{
			_soundChannel.stop();
			_sound.close();
		}
	}
	
	/**
	 * Seeks 8 seconds forward from the current position.
	 * @return current play time after forward
	 */
	public function forward():Float
	{	
		var seekTime = (getTime() + 8) + _startTime;
		
		if (getDuration() > seekTime)
		{
			seekTime = seek(seekTime);
		}
		
		return seekTime;
	}
	
	/**
	 * Seeks 8 seconds back from the current position.
	 * @return current play time after rewind
	 */
	public function rewind():Float
	{
		var seekTime = (getTime() - 8) + _startTime;
		
		if (seekTime >= _startTime)
		{
			seekTime = seek(seekTime);
		}
		
		return seekTime;
	}
	
	/**
	 * Seeks video player to a given time in seconds
	 * @param	seekTime time in seconds to seek
	 * @return current play time after seeking
	 */
	public function seek(seekTime:Float):Float
	{
		if (_startTime <= 1 && _downloadCompleted)
		{
			if (_type == InputType.VIDEO)
			{
				_stream.seek(seekTime);
			}
			else if (_type == InputType.AUDIO)
			{
				_soundChannel.stop();
				_soundChannel = _sound.play(seekTime * 1000);
				if (!_isPlaying)
				{
					_soundChannel.stop();
				}
			}
		}
		else if(_seekPoints.length > 0 && _streamType == StreamType.PSEUDOSTREAM)
		{
			seekTime = getBestSeekPoint(seekTime);
			
			if (canSeek(seekTime))
			{
				_stream.seek(seekTime);
			}
			else if(seekTime != _startTime)
			{	
				var url:String;
				if (_mediaSource.indexOf("?") != -1)
				{
					url = _mediaSource + "&start=" + seekTime;
				}
				else
				{
					url = _mediaSource + "?start=" + seekTime;
				}
				
				_startTime = seekTime;
				_stream.play(url);
			}
		}
		else if(canSeek(seekTime))
		{
			if (_type == InputType.VIDEO)
			{
				seekTime = getBestSeekPoint(seekTime);
				_stream.seek(seekTime);
			}
			else if (_type == InputType.AUDIO)
			{
				_soundChannel.stop();
				_soundChannel = _sound.play(seekTime * 1000);
				if (!_isPlaying)
				{
					_soundChannel.stop();
				}
			}
		}
		
		return seekTime;
	}
	
	/**
	 * To check wheter the media is playing
	 * @return true if is playing false otherwise
	 */
	public function isPlaying():Bool
	{
		return _isPlaying;
	}
	
	/**
	 * Cycle betewen aspect ratios
	 * @return new aspect ratio in use
	 */
	public function toggleAspectRatio():Float
	{
		switch(_aspectRatio)
		{
			case _originalAspectRatio:
				_aspectRatio = AspectRatio._1_1;
				
			case AspectRatio._1_1:
				_aspectRatio = AspectRatio._3_2;
				
			case AspectRatio._3_2:
				_aspectRatio = AspectRatio._4_3;
				
			case AspectRatio._4_3:
				_aspectRatio = AspectRatio._5_4;
				
			case AspectRatio._5_4:
				_aspectRatio = AspectRatio._14_9;
				
			case AspectRatio._14_9:
				_aspectRatio = AspectRatio._14_10;
				
			case AspectRatio._14_10:
				_aspectRatio = AspectRatio._16_9;
				
			case AspectRatio._16_9:
				_aspectRatio = AspectRatio._16_10;
				
			case AspectRatio._16_10:
				_aspectRatio = _originalAspectRatio;
			
			default:
				_aspectRatio = _originalAspectRatio;
		}
		
		resizeAndCenterPlayer();
		
		return _aspectRatio;
	}
	
	/**
	 * Swithces between play and pause
	 */
	public function togglePlay():Bool
	{
		if (_mediaLoaded)
		{
			if (_mediaEndReached)
			{
				_mediaEndReached = false;
				
				if (_type == InputType.VIDEO)
				{
					_stream.seek(0);
					_stream.togglePause();
				}
				else if (_type == InputType.AUDIO)
				{
					_checkAudioTimer.start();
					_soundChannel = _sound.play();
				}
			}
			else if (_mediaLoaded)
			{
				if (_type == InputType.VIDEO)
				{
					_stream.togglePause();
				}
				else if (_type == InputType.AUDIO)
				{
					if (_isPlaying)
					{
						_soundChannel.stop();
					}
					else
					{
						//If end of audio reached start from beggining
						if (_soundChannel.position + 100 >= _sound.length)
						{
							_soundChannel = _sound.play();
						}
						else 
						{
							_soundChannel = _sound.play(_soundChannel.position);
						}
					}
				}
			}
			else if (_stopped)
			{
				load(_mediaSource, _type, _streamType, _server);
			}
			
			_isPlaying = !_isPlaying;
			
			return _isPlaying;
		}
		else if(_mediaSource != "")
		{
			load(_mediaSource, _type, _streamType, _server);
			
			return true;
		}
		
		return false;
	}
	
	/**
	 * Switches on or off fullscreen
	 * @return true if fullscreen otherwise false
	 */
	public function toggleFullscreen():Bool 
	{
		if (_fullscreen)
		{
			_stage.displayState = StageDisplayState.NORMAL;
			_stage.focus = _stage;
			return false;
		}
		else
		{	
			if (_useHardWareScaling)
			{
				//Match full screen aspec ratio to desktop
				var aspectRatio = Capabilities.screenResolutionY / Capabilities.screenResolutionX;
				_stage.fullScreenSourceRect = new Rectangle(0, 0, _videoWidth, _videoWidth * aspectRatio);
			}
			else
			{
				//Use desktop resolution
				_stage.fullScreenSourceRect = new Rectangle(0, 0, Capabilities.screenResolutionX ,Capabilities.screenResolutionY);
			}
			
			_stage.displayState = StageDisplayState.FULL_SCREEN;
			_stage.focus = _stage;
			return true;
		}
	}
	
	/**
	 * Toggles betewen high and low quality image rendering
	 * @return true if quality high false otherwise
	 */
	public function toggleQuality():Bool
	{
		if (_videoQualityHigh)
		{
			_video.smoothing = false;
			_video.deblocking = 1;
		}
		else
		{
			_video.smoothing = true;
			_video.deblocking = 5;
		}
		
		_videoQualityHigh = _videoQualityHigh?false:true;
		
		return _videoQualityHigh;
	}
	
	/**
	 * Mutes or unmutes the sound
	 * @return true if muted false if unmuted
	 */
	public function toggleMute():Bool
	{
		var soundTransform:SoundTransform = new SoundTransform();
		var isMute:Bool;
		
		//unmute sound
		if (_soundMuted)
		{
			_soundMuted = false;
			
			if (_volume > 0)
			{
				soundTransform.volume = _volume;
			}
			else
			{
				_volume = 1.0;
				soundTransform.volume = _volume;
			}
			
			_stream.soundTransform = soundTransform;
			
			isMute =  false;
		}
		
		//mute sound
		else
		{
			_soundMuted = true;
			_volume = _stream.soundTransform.volume;
			soundTransform.volume = 0;
			_stream.soundTransform = soundTransform;
			
			isMute = true;
		}
		
		if (_type == InputType.VIDEO)
		{
			_stream.soundTransform = soundTransform;
		}
		else if (_type == InputType.AUDIO)
		{
			_soundChannel.soundTransform = soundTransform;
		}
		
		return isMute;
	}
	
	/**
	 * Check if player is running on fullscreen mode
	 * @return true if fullscreen false if not
	 */
	public function isFullscreen():Bool
	{
		return _stage.displayState == StageDisplayState.FULL_SCREEN;
	}
	
	/**
	 * Raises the volume
	 * @return volume value after raising
	 */
	public function volumeUp():Float
	{
		var soundTransform:SoundTransform = new SoundTransform();
		
		if (_soundMuted)
		{
			_soundMuted = false;
		}
	
		//raise volume if not already at max
		if (_volume < 1)
		{
			if (_type == InputType.VIDEO)
			{
				_volume = _stream.soundTransform.volume + (10/100);
				soundTransform.volume = _volume;
				_stream.soundTransform = soundTransform;
			}
			else if (_type == InputType.AUDIO)
			{
				_volume = _soundChannel.soundTransform.volume + (10/100);
				soundTransform.volume = _volume;
				_soundChannel.soundTransform = soundTransform;
			}
		}
		
		//reset volume to 1.0 if already reached max
		if (_volume >= 1)
		{
			_volume = 1.0;
		}
		
		return _volume;
	}
	
	/**
	 * Lower the volume
	 * @return volume value after lowering
	 */
	public function volumeDown():Float
	{
		var soundTransform:SoundTransform = new SoundTransform();
		
		//lower sound
		if(!_soundMuted)
		{	
			if (_type == InputType.VIDEO)
			{
				_volume = _stream.soundTransform.volume - (10/100);
				soundTransform.volume = _volume;
				_stream.soundTransform = soundTransform;
			}
			else if (_type == InputType.AUDIO)
			{
				_volume = _soundChannel.soundTransform.volume - (10/100);
				soundTransform.volume = _volume;
				_soundChannel.soundTransform = soundTransform;
			}
			
			//if volume reached min is muted
			if (_volume <= 0)
			{
				_soundMuted = true;
				_volume = 0;
			}
		}
		
		return _volume;
	}
	//}
	
	
	//{Setters
	/**
	 * Set input type
	 * @param	type Allowable values are audio, video
	 */
	public function setType(type:String):Void
	{
		_type = type;
	}
	
	/**
	 * Set streaming type
	 * @param	streamType Allowable values are file, http, rmtp
	 */
	public function setStreamType(streamType:String):Void
	{
		_streamType = streamType;
	}
	 
	/**
	 * To set a reference to a poster image that should be disabled when media is loaded and ready to play
	 * @param	poster
	 */
	public function setPoster(poster:Poster)
	{
		_poster = poster;
	}
	
	/**
	 * To set the video source in case we dont want to start downloading at first so when use tooglePlay the
	 * media is loaded automatically
	 * @param	source
	 */
	public function setSource(source):Void
	{
		_mediaSource = source;
	}
	
	/**
	 * Changes the current volume
	 * @param	volume
	 */
	public function setVolume(volume:Float):Void
	{
		var soundTransform:SoundTransform = new SoundTransform();
		
		if (volume > 0)
		{
			_soundMuted = false;
			_volume = volume;
		}
		else
		{
			_soundMuted = true;
			_volume = 1.0;
		}
		
		soundTransform.volume = volume;
		
		if (_type == InputType.VIDEO)
		{
			_stream.soundTransform = soundTransform;
		}
		else if (_type == InputType.AUDIO)
		{
			_soundChannel.soundTransform = soundTransform;
		}
	}
	
	/**
	 * Changes the aspec ratio of current playing media and resizes video player
	 * @param	aspectRatio new aspect ratio value
	 */
	public function setAspectRatio(aspectRatio:Float):Void
	{
		_aspectRatio = aspectRatio;
		
		resizeAndCenterPlayer();
	}
	
	/**
	 * Enable or disable hardware scaling
	 * @param	value true to enable false to disable
	 */
	public function setHardwareScaling(value:Bool):Void
	{
		_useHardWareScaling = value;
	}
	//}
	
	
	//{Getters
	/**
	 * Current playtime of the loaded video
	 * @return
	 */
	public function getTime():Float
	{
		var time:Float = 0;
		
		if(_type == InputType.VIDEO)
		{
			time = _stream.time;
		}
		else if (_type == InputType.AUDIO)
		{
			time = _soundChannel.position / 1000;
		}
		
		return time;
	}
	
	/**
	 * Gets the volume amount 0.0 to 1.0
	 * @return 
	 */
	public function getVolume():Float
	{
		return _volume;
	}
	
	/**
	 * The current aspect ratio of the loaded Player
	 * @return
	 */
	public function getAspectRatio():Float
	{
		return _aspectRatio;
	}
	
	/**
	 * Original aspect ratio of the video
	 * @return original aspect ratio
	 */
	public function getOriginalAspectRatio():Float
	{
		return _originalAspectRatio;
	}
	
	/**
	 * Total duration time of the loaded media
	 * @return time in seconds
	 */
	public function getDuration():Float
	{
		return _mediaDuration;
	}
	
	/**
	 * The time in seconds where the player started downloading
	 * @return time in seconds
	 */
	public function getStartTime():Float
	{
		return _startTime;
	}
	
	/**
	 * The stream associated with the player
	 * @return netstream object
	 */
	public function getNetStream():NetStream
	{
		return _stream;
	}
	
	/**
	 * Video object associated to the player
	 * @return video object for further manipulation
	 */
	public function getVideo():Video
	{
		return _video;
	}
	
	/**
	 * Sound object associated to the player
	 * @return sound object for further manipulation
	 */
	public function getSound():Sound
	{
		return _sound;
	}
	
	/**
	 * The current sound state
	 * @return true if mute otherwise false
	 */
	public function getMute():Bool
	{
		return _soundMuted;
	}
	
	/**
	 * The amount of total bytes
	 * @return amount of bytes
	 */
	public function getBytesTotal():Float
	{
		var bytesTotal:Float = 0;
		
		if (_type == InputType.VIDEO)
		{
			bytesTotal = _stream.bytesTotal;
		}
		else if (_type == InputType.AUDIO)
		{
			bytesTotal = _sound.bytesTotal;
		}
		
		return bytesTotal;
	}
	
	/**
	 * The amount of bytes loaded
	 * @return amount of bytes
	 */
	public function getBytesLoaded():Float
	{
		var bytesLoaded:Float = 0;
		
		if (_type == InputType.VIDEO)
		{
			bytesLoaded = _stream.bytesLoaded;
		}
		else if (_type == InputType.AUDIO)
		{
			bytesLoaded = _sound.bytesLoaded;
		}
		
		return bytesLoaded;
	}
	
	/**
	 * Current playing file type
	 * @return audio or video
	 */
	public function getType():String
	{
		return _type;
	}
	
	/**
	 * To check current quality mode
	 * @return true if high quality false if low
	 */
	public function getQuality():Bool
	{
		return _videoQualityHigh;
	}
	
	/**
	 * The current playing time
	 * @return current playing time in seconds
	 */
	public function getCurrentTime():Float
	{
		var time:Float = 0;
		if (_type == InputType.VIDEO)
		{
			time = _stream.time;
		}
		else if (_type == InputType.AUDIO)
		{
			if(_soundChannel != null)
			{	
				time = _soundChannel.position / 1000;
			}
			else
			{
				time = 0;
			}
		}
		
		return time;
	}
	//}
}