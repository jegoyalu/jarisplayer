/**
 * ...
 * @author Jefferson González
 */

package jaris.player;

//{Libraries
import flash.display.GradientType;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.Lib;
import flash.events.MouseEvent;
import flash.display.MovieClip;
import flash.net.NetStream;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;
import jaris.animation.Animation;
import jaris.display.Loader;
import jaris.events.PlayerEvents;
import jaris.player.Player;
import flash.display.Sprite;
import flash.display.Stage;
import jaris.utils.Utils;
//}

/**
 * Default controls for jaris player
 */
class Controls extends MovieClip {
	
	//{Member Variables
	private var _thumb:Sprite;
	private var _track:Sprite;
	private var _trackDownloaded:Sprite;
	private var _trackBar:Sprite;
	private var _scrubbing:Bool;
	private var _stage:Stage;
	private var _movieClip:MovieClip;
	private var _player:Player;
	private var _darkColor:UInt;
	private var _brightColor:UInt;
	private var _controlColor:UInt;
	private var _hoverColor:UInt;
	private var _hideControlsTimer:Timer;
	private var _currentPlayTimeLabel:TextField;
	private var _totalPlayTimeLabel:TextField;
	private var _seekPlayTimeLabel:TextField;
	private var _percentLoaded:Float;
	private var _controlsVisible:Bool;
	private var _seekBar:Sprite;
	private var _controlsBar:Sprite;
	private var _playControl:Sprite;
	private var _pauseControl:Sprite;
	private var _aspectRatioControl:Sprite;
	private var _fullscreenControl:Sprite;
	private var _volumeIcon:Sprite;
	private var _volumeTrack:Sprite;
	private var _volumeSlider:Sprite;
	private var _loader:Loader;
	//}
	
	
	//{Constructor
	public function new(player:Player)
	{
		super();
		
		//{Main variables
		_stage = Lib.current.stage;
		_movieClip = Lib.current;
		_player = player;
		_darkColor = 0x000000;
		_brightColor = 0x4c4c4c;
		_controlColor = 0xFFFFFF;
		_hoverColor = 0x67A8C1;
		_percentLoaded = 0.0;
		_hideControlsTimer = new Timer(500);
		_controlsVisible = false;
		//}
		
		//{Seeking Controls initialization
		_seekBar = new Sprite();
		addChild(_seekBar);
		
		_trackBar = new Sprite(  );
		_trackBar.tabEnabled = false;
		_seekBar.addChild(_trackBar);
		
		_trackDownloaded = new Sprite(  );
		_trackDownloaded.tabEnabled = false;
		_seekBar.addChild(_trackDownloaded);
		
		_track = new Sprite(  );
		_track.tabEnabled = false;
		_track.buttonMode = true;
		_track.useHandCursor = true;
		_seekBar.addChild(_track);
		
		
		_thumb = new Sprite(  );
		_thumb.buttonMode = true;
		_thumb.useHandCursor = true;
		_thumb.tabEnabled = false;
		_seekBar.addChild(_thumb);
		
		_currentPlayTimeLabel = new TextField();
		_currentPlayTimeLabel.autoSize = TextFieldAutoSize.LEFT;
		_currentPlayTimeLabel.text = "00:00:00";
		_currentPlayTimeLabel.tabEnabled = false;
		_seekBar.addChild(_currentPlayTimeLabel);
		
		_totalPlayTimeLabel = new TextField();
		_totalPlayTimeLabel.autoSize = TextFieldAutoSize.LEFT;
		_totalPlayTimeLabel.text = "00:00:00";
		_totalPlayTimeLabel.tabEnabled = false;
		_seekBar.addChild(_totalPlayTimeLabel);
		
		_seekPlayTimeLabel = new TextField();
		_seekPlayTimeLabel.visible = false;
		_seekPlayTimeLabel.autoSize = TextFieldAutoSize.LEFT;
		_seekPlayTimeLabel.text = "00:00:00";
		_seekPlayTimeLabel.tabEnabled = false;
		addChild(_seekPlayTimeLabel);
		
		drawSeekControls();
		//}
		
		//{Playing controls initialization
		_controlsBar = new Sprite();
		_controlsBar.visible = true;
		addChild(_controlsBar);
		
		_playControl = new Sprite();
		_playControl.buttonMode = true;
		_playControl.useHandCursor = true;
		_playControl.tabEnabled = false;
		_controlsBar.addChild(_playControl);
		
		_pauseControl = new Sprite();
		_pauseControl.visible = false;
		_pauseControl.buttonMode = true;
		_pauseControl.useHandCursor = true;
		_pauseControl.tabEnabled = false;
		_controlsBar.addChild(_pauseControl);
		
		_aspectRatioControl = new Sprite();
		_aspectRatioControl.buttonMode = true;
		_aspectRatioControl.useHandCursor = true;
		_aspectRatioControl.tabEnabled = false;
		_controlsBar.addChild(_aspectRatioControl);
		
		_fullscreenControl = new Sprite();
		_fullscreenControl.buttonMode = true;
		_fullscreenControl.useHandCursor = true;
		_fullscreenControl.tabEnabled = false;
		_controlsBar.addChild(_fullscreenControl);
		
		_volumeIcon = new Sprite();
		_volumeIcon.buttonMode = true;
		_volumeIcon.useHandCursor = true;
		_volumeIcon.tabEnabled = false;
		_controlsBar.addChild(_volumeIcon);
		
		_volumeSlider = new Sprite();
		_controlsBar.addChild(_volumeSlider);
		
		_volumeTrack = new Sprite();
		_volumeTrack.buttonMode = true;
		_volumeTrack.useHandCursor = true;
		_volumeTrack.tabEnabled = false;
		_controlsBar.addChild(_volumeTrack); 
		//}
		
		//{Loader bar
		_loader = new Loader();
		_loader.visible = false;
		
		var loaderColors:Array <String> = ["", "", "", ""];
		loaderColors[0] = Std.string(_brightColor);
		loaderColors[1] = Std.string(_controlColor);
		
		_loader.setColors(loaderColors);
		
		addChild(_loader);
		//}
		
		//{event Listeners
		_movieClip.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		_thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
		_thumb.addEventListener(MouseEvent.MOUSE_UP, onThumbMouseUp);
		_thumb.addEventListener(MouseEvent.MOUSE_OVER, onThumbHover);
		_thumb.addEventListener(MouseEvent.MOUSE_OUT, onThumbMouseOut);
		_thumb.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
		_thumb.addEventListener(MouseEvent.MOUSE_OUT, onTrackMouseOut);
		_track.addEventListener(MouseEvent.CLICK, onTrackClick);
		_track.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
		_track.addEventListener(MouseEvent.MOUSE_OUT, onTrackMouseOut);
		_trackBar.addEventListener(MouseEvent.MOUSE_OUT, onThumbMouseUp);
		_controlsBar.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		_controlsBar.addEventListener(MouseEvent.MOUSE_OVER, onMouseMove);
		_playControl.addEventListener(MouseEvent.CLICK, onPlayClick);
		_playControl.addEventListener(MouseEvent.MOUSE_OVER, onPlayButtonHover);
		_playControl.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutRedrawControlBar);
		_pauseControl.addEventListener(MouseEvent.CLICK, onPauseClick);
		_pauseControl.addEventListener(MouseEvent.MOUSE_OVER, onPauseButtonHover);
		_pauseControl.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutRedrawControlBar);
		_aspectRatioControl.addEventListener(MouseEvent.CLICK, onAspectRatioClick);
		_aspectRatioControl.addEventListener(MouseEvent.MOUSE_OVER, onAspectRatioButtonHover);
		_aspectRatioControl.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutRedrawControlBar);
		_fullscreenControl.addEventListener(MouseEvent.CLICK, onFullscreenClick);
		_fullscreenControl.addEventListener(MouseEvent.MOUSE_OVER, onFullscreenButtonHover);
		_fullscreenControl.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutRedrawControlBar);
		_volumeIcon.addEventListener(MouseEvent.CLICK, onVolumeIconClick);
		_volumeIcon.addEventListener(MouseEvent.MOUSE_OVER, onVolumeIconButtonHover);
		_volumeIcon.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutRedrawControlBar);
		_volumeTrack.addEventListener(MouseEvent.CLICK, onVolumeTrackClick);
		
		_player.addEventListener(PlayerEvents.FULLSCREEN, onPlayerFullScreen);
		_player.addEventListener(PlayerEvents.MOUSE_HIDE, onPlayerMouseHide);
		_player.addEventListener(PlayerEvents.MOUSE_SHOW, onPlayerMouseShow);
		_player.addEventListener(PlayerEvents.META_RECIEVED, onPlayerMetaData);
		_player.addEventListener(PlayerEvents.BUFFERING, onPlayerBuffering);
		_player.addEventListener(PlayerEvents.NOT_BUFFERING, onPlayerNotBuffering);
		_player.addEventListener(PlayerEvents.RESIZE, onPlayerResize);
		_player.addEventListener(PlayerEvents.PLAY_PAUSE, onPlayerPlayPause);
		_player.addEventListener(PlayerEvents.PLAYBACK_FINISHED, onPlayerPlaybackFinished);
		_player.addEventListener(PlayerEvents.CONNECTION_FAILED, onPlayerStreamNotFound);
		
		_stage.addEventListener(MouseEvent.MOUSE_UP, onThumbMouseUp);
		_stage.addEventListener(MouseEvent.MOUSE_OUT, onThumbMouseUp);
		_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		
		_hideControlsTimer.addEventListener(TimerEvent.TIMER, hideControlsTimer);
		
		_hideControlsTimer.start();
		//}
	}
	//}

	
	//{Timers
	/**
	 * Hides the playing controls when not moving mouse.
	 * @param	event The timer event associated
	 */
	private function hideControlsTimer(event:TimerEvent):Void
	{
		if (_player.isPlaying())
		{
			if (_controlsVisible)
			{
				if (_stage.mouseX < _controlsBar.x)
				{
					_controlsVisible = false;
				}
			}
			else
			{
				hideControls();
				_hideControlsTimer.stop();
			}
		}
	}
	//}
	
	
	//{Events
	/**
	 * Keeps syncronized various elements of the controls like the thumb and download track bar
	 * @param	event
	 */
	private function onEnterFrame(event:Event)
	{
		if(_player.getDuration() > 0) {
			if(_scrubbing) {
				_player.seek(_player.getDuration() * (_thumb.x / _track.width));
			}
			else {
				_currentPlayTimeLabel.text = Utils.formatTime(_player.getTime());
				_thumb.x = (_player.getTime()+_player.getStartTime()) / _player.getDuration() * (_track.width-_thumb.width);
			}
		}
		
		_volumeSlider.height = _volumeTrack.height * (_player.getVolume() / 1.0);
		_volumeSlider.y = (_volumeTrack.y + _volumeTrack.height) - _volumeSlider.height;
		
		drawDownloadProgress();
	}
	
	/**
	 * Show playing controls on mouse movement.
	 * @param	event
	 */
	private function onMouseMove(event:MouseEvent):Void
	{
		if (_stage.mouseX >= _controlsBar.x)
		{
			if (!_hideControlsTimer.running)
			{
				_hideControlsTimer.start();
			}
			
			_controlsVisible = true;
			showControls();
		}
	}
	
	/**
	 * Used for various controls to redraw controbar after mouse out to clear hover effect
	 * @param	event
	 */
	private function onMouseOutRedrawControlBar(event:MouseEvent)
	{
		drawPlayingControls();
	}
	
	/**
	 * Toggles pause or play
	 * @param	event
	 */
	private function onPlayClick(event:MouseEvent):Void
	{
		_player.togglePlay();
		_playControl.visible = !_player.isPlaying();
		_pauseControl.visible = _player.isPlaying();
	}
	
	/**
	 * Changes play control color to hover color
	 * @param	event
	 */
	private function onPlayButtonHover(event:MouseEvent):Void
	{
		var triangleRatio = ((80 / 100) * (_controlsBar.width - 20));
		_playControl.graphics.clear();
		_playControl.graphics.lineStyle();
		_playControl.graphics.beginFill(_hoverColor);
		Utils.drawTriangle(_playControl, 0, 0, triangleRatio, 0);
		_playControl.graphics.endFill();
	}
	
	/**
	 * Toggles pause or play
	 * @param	event
	 */
	private function onPauseClick(event:MouseEvent):Void
	{
		_player.togglePlay();
		_playControl.visible = !_player.isPlaying();
		_pauseControl.visible = _player.isPlaying();
	}
	
	/**
	 * Changes pause button color to hover color
	 * @param	event
	 */
	private function onPauseButtonHover(event:MouseEvent):Void
	{
		_pauseControl.graphics.lineStyle();
		_pauseControl.graphics.beginFill(_hoverColor);
		_pauseControl.graphics.drawRoundRect(0, 0, (33 / 100) * _playControl.width, _playControl.height, 6, 6);
		_pauseControl.graphics.drawRoundRect(_playControl.width - ((33 / 100) * _playControl.width), 0, (33 / 100) * _playControl.width, _playControl.height, 6, 6);
		_pauseControl.graphics.endFill();
		
		_pauseControl.graphics.lineStyle();
		_pauseControl.graphics.beginFill(0x000000, 0);
		_pauseControl.graphics.drawRect(0, 0, _pauseControl.width, _playControl.height);
		_pauseControl.graphics.endFill();
	}
	
	/**
	 * Toggles betewen aspect ratios
	 * @param	event
	 */
	private function onAspectRatioClick(event:MouseEvent):Void
	{
		_player.toggleAspectRatio();
	}
	
	/**
	 * Changes aspect ratio icon color to hover one
	 * @param	event
	 */
	private function onAspectRatioButtonHover(event:MouseEvent):Void
	{
		_aspectRatioControl.graphics.clear();
		
		_aspectRatioControl.graphics.lineStyle(2, _hoverColor);
		_aspectRatioControl.graphics.drawRect(0, 0, _playControl.width, _playControl.height);
		
		_aspectRatioControl.graphics.lineStyle();
		_aspectRatioControl.graphics.beginFill(_hoverColor, 1);
		_aspectRatioControl.graphics.drawRect(5, 5, _aspectRatioControl.width - 12, _aspectRatioControl.height - 12);
		_aspectRatioControl.graphics.endFill();
		
		_aspectRatioControl.graphics.lineStyle();
		_aspectRatioControl.graphics.beginFill(0x000000, 0);
		_aspectRatioControl.graphics.drawRect(0, 0, _aspectRatioControl.width, _aspectRatioControl.height);
		_aspectRatioControl.graphics.endFill();
	}
	
	/**
	 * Toggles between window and fullscreen mode
	 * @param	event
	 */
	private function onFullscreenClick(event:MouseEvent)
	{
		_player.toggleFullscreen();
	}
	
	/**
	 * Changes fullscreen icon color to hover one
	 * @param	event
	 */
	private function onFullscreenButtonHover(event:MouseEvent):Void
	{
		_fullscreenControl.graphics.lineStyle(2, _hoverColor);
		_fullscreenControl.graphics.beginFill(0x000000, 0);
		_fullscreenControl.graphics.drawRoundRect(0, 0, _playControl.width, _playControl.height, 6, 6);
		_fullscreenControl.graphics.endFill();
		
		_fullscreenControl.graphics.lineStyle();
		_fullscreenControl.graphics.beginFill(_hoverColor, 1);
		_fullscreenControl.graphics.drawRoundRect(3, 3, 4, 4, 2, 2);
		_fullscreenControl.graphics.drawRoundRect(_fullscreenControl.width - 9, 3, 4, 4, 2, 2);
		_fullscreenControl.graphics.drawRoundRect(3, _fullscreenControl.height - 9, 4, 4, 2, 2);
		_fullscreenControl.graphics.drawRoundRect(_fullscreenControl.width - 9, _fullscreenControl.height - 9, 4, 4, 2, 2);
		_fullscreenControl.graphics.endFill();
	}
	
	/**
	 * Toggles between mute and unmute
	 * @param	event
	 */
	public function onVolumeIconClick(event: MouseEvent)
	{
		_player.toggleMute();
	}
	
	/**
	 * Changes volume icon color to hover one
	 * @param	event
	 */
	public function onVolumeIconButtonHover(event: MouseEvent)
	{
		_volumeIcon.graphics.lineStyle();
		_volumeIcon.graphics.beginFill(_hoverColor, 1);
		_volumeIcon.graphics.drawRect(0, ((50 / 100) * _playControl.height) / 2, _playControl.width / 2, ((50 / 100) * _playControl.height));
		_volumeIcon.graphics.moveTo(_playControl.width / 2, ((50 / 100) * _playControl.height)/2);
		_volumeIcon.graphics.lineTo(_playControl.width, 0);
		_volumeIcon.graphics.lineTo(_playControl.width, _playControl.height);
		_volumeIcon.graphics.lineTo(_playControl.width / 2, ((50 / 100) * _playControl.height) + (((50 / 100) * _playControl.height) / 2));
		_volumeIcon.graphics.endFill();
	}
	
	/**
	 * Detect user click on volume track control and change volume according
	 * @param	event
	 */
	private function onVolumeTrackClick(event:MouseEvent)
	{
		var percent:Float = _volumeTrack.height - _volumeTrack.mouseY;
		var volume:Float = 1.0 * (percent / _volumeTrack.height);
		
		_player.setVolume(volume);
	}
	
	/**
	 * Display not found message
	 * @param	event
	 */
	private function onPlayerStreamNotFound(event:PlayerEvents):Void
	{
		//todo: to work on this
	}	
	
	/**
	 * Shows the loader bar when buffering
	 * @param	event
	 */
	private function onPlayerBuffering(event:PlayerEvents):Void
	{
		_loader.visible = true;
	}
	
	/**
	 * Hides loader bar when not buffering
	 * @param	event
	 */
	private function onPlayerNotBuffering(event:PlayerEvents):Void
	{
		_loader.visible = false;
	}
		
	/**
	 * Monitors playbeack when finishes tu update controls
	 * @param	event
	 */
	private function onPlayerPlaybackFinished(event:PlayerEvents):Void
	{
		_playControl.visible = !_player.isPlaying();
		_pauseControl.visible = _player.isPlaying();
		showControls();
	}
	
	/**
	 * Monitors keyboard play pause actions to update icons
	 * @param	event
	 */
	private function onPlayerPlayPause(event:PlayerEvents)
	{
		_playControl.visible = !_player.isPlaying();
		_pauseControl.visible = _player.isPlaying();
	}
	
	/**
	 * Function fired by the player FULLSCREEN event that redraws the player controls
	 * @param	event
	 */
	private function onPlayerFullScreen(event:PlayerEvents)
	{
		redrawControls();
		
		//Need to check when hardware scaling enabled
		//Limit check to 3 in case of hanging (infinite loop)
		var count:UInt = 1;
		while (_seekBar.width != _stage.stageWidth && count <= 3)
		{
			redrawControls();
			hideControls();
			count++;
		}
	}
	
	/**
	 * Resizes the video player on windowed mode substracting the seekbar height
	 * @param	event
	 */
	private function onPlayerResize(event:PlayerEvents)
	{
		if (!_player.isFullscreen())
		{
			_player.getVideo().height = _stage.stageHeight - _trackBar.height;
			_player.getVideo().width = _player.getVideo().height * _player.getAspectRatio();
			
			_player.getVideo().x = (_stage.stageWidth / 2) - (_player.getVideo().width / 2);
		}
	}
	
	/**
	 * Updates media total time duration.
	 * @param	event
	 */
	private function onPlayerMetaData(event:PlayerEvents):Void
	{
		_totalPlayTimeLabel.text = Utils.formatTime(event.duration);
		_playControl.visible = !_player.isPlaying();
		_pauseControl.visible = _player.isPlaying();
	}
	
	/**
	 * Hides seekbar if on fullscreen.
	 * @param	event
	 */
	private function onPlayerMouseHide(event:PlayerEvents)
	{
		if (_seekBar.visible && _player.isFullscreen())
		{
			Animation.slideOut(_seekBar, "bottom", 1000);
		}
	}
	
	/**
	 * Shows seekbar
	 * @param	event
	 */
	private function onPlayerMouseShow(event:PlayerEvents)
	{
		//Only use slidein effect on fullscreen since switching to windowed mode on
		//hardware scaling causes a bug by a slow response on stage height changes
		if (_player.isFullscreen() && !_seekBar.visible)
		{
			Animation.slideIn(_seekBar, "bottom",1000);
		}
		else
		{
			_seekBar.visible = true;
		}
	}
	
	/**
	 * Translates a user click in to time and seeks to it
	 * @param	event
	 */
	private function onTrackClick(event:MouseEvent)
	{
		var clickPosition:Float = _track.mouseX - _currentPlayTimeLabel.width;
		_player.seek(_player.getDuration() * (clickPosition / _track.width));
	}
	
	/**
	 * Shows a small tooltip showing the time calculated by mouse position
	 * @param	event
	 */
	private function onTrackMouseMove(event:MouseEvent):Void
	{
		var clickPosition:Float = _track.mouseX - _currentPlayTimeLabel.width;
		_seekPlayTimeLabel.text = Utils.formatTime(_player.getDuration() * (clickPosition / _track.width));
		
		_seekPlayTimeLabel.y = _stage.stageHeight - _trackBar.height - _seekPlayTimeLabel.height - 1;
		_seekPlayTimeLabel.x = clickPosition + (_seekPlayTimeLabel.width / 2);
		
		_seekPlayTimeLabel.backgroundColor = _brightColor;
		_seekPlayTimeLabel.background = true;
		_seekPlayTimeLabel.textColor = _controlColor;
		_seekPlayTimeLabel.borderColor = _darkColor;
		_seekPlayTimeLabel.border = true;
		
		if (!_seekPlayTimeLabel.visible)
		{
			Animation.fadeIn(_seekPlayTimeLabel, 300);
		}
	}
	
	/**
	 * Hides the tooltip that shows the time calculated by mouse position
	 * @param	event
	 */
	private function onTrackMouseOut(event:MouseEvent):Void
	{
		Animation.fadeOut(_seekPlayTimeLabel, 300);
	}
	
	/**
	 * Enables dragging of thumb for seeking media
	 * @param	event
	 */
	private function onThumbMouseDown(event:MouseEvent)
	{
		_scrubbing = true;
		var rectangle:Rectangle = new Rectangle(_track.x, _track.y, _track.width-_thumb.width, 0);
		_thumb.startDrag(false, rectangle);
	}
	
	/**
	 * Changes thumb seek control to hover color
	 * @param	event
	 */
	private function onThumbHover(event:MouseEvent)
	{
		_thumb.graphics.lineStyle();
		_thumb.graphics.beginFill(_hoverColor);
		_thumb.graphics.drawRect(_currentPlayTimeLabel.width, (_seekBar.height/2)-(10/2), 10, 10);
		_thumb.graphics.endFill();
	}
	
	/**
	 * Changes thumb seek control to control color
	 * @param	event
	 */
	private function onThumbMouseOut(event:MouseEvent)
	{
		_thumb.graphics.lineStyle();
		_thumb.graphics.beginFill(_controlColor);
		_thumb.graphics.drawRect(_currentPlayTimeLabel.width, (_seekBar.height/2)-(10/2), 10, 10);
		_thumb.graphics.endFill();
	}
	
	/**
	 * Disables dragging of thumb
	 * @param	event
	 */
	private function onThumbMouseUp(event:MouseEvent) 
	{
		_scrubbing = false;
		_thumb.stopDrag(  );
	}
	//}
	
	
	//{Drawing functions
	/**
	 * Clears all current graphics a draw new ones
	 */
	private function redrawControls():Void
	{
		_seekBar.graphics.clear();
		_trackBar.graphics.clear();
		_track.graphics.clear();
		_thumb.graphics.clear();
		
		drawSeekControls();
		drawPlayingControls();
	}
	
	/**
	 * Draws the download progress track bar
	 */
	private function drawDownloadProgress():Void
	{
		if (_player.getNetStream().bytesTotal > 0)
		{
			var bytesLoaded:Float = _player.getNetStream().bytesLoaded;
			var bytesTotal:Float = _player.getNetStream().bytesTotal;
			
			_percentLoaded = bytesLoaded / bytesTotal;
		}
		
		var position:Float = _player.getStartTime() / _player.getDuration();
		
		_trackDownloaded.graphics.clear();
		
		_trackDownloaded.graphics.lineStyle();
		_trackDownloaded.graphics.beginFill(_brightColor, 0xFFFFFF);
		_trackDownloaded.graphics.drawRect(_currentPlayTimeLabel.width + (position * _track.width), (_seekBar.height / 2) - (10 / 2), _track.width * _percentLoaded, 10);
		_trackDownloaded.graphics.endFill();
	}
	
	/**
	 * Draws all seekbar controls
	 */
	private function drawSeekControls()
	{
		_seekBar.x = 0;
		_seekBar.y = _stage.stageHeight - 25;
		_seekBar.graphics.lineStyle();
		_seekBar.graphics.beginFill(0x000000, 0);
		_seekBar.graphics.drawRect(0, 0, _stage.stageWidth, 25);
		_seekBar.graphics.endFill();
		_seekBar.width = _stage.stageWidth;	
		_seekBar.height = 25;
		
		var matrix:Matrix = new Matrix(  );
		matrix.createGradientBox(_seekBar.width, 25, Utils.degreesToRadians(90), 0, _seekBar.height-25);
		var colors:Array<UInt> = [_brightColor, _darkColor];
		var alphas:Array<UInt> = [1, 1];
		var ratios:Array<UInt> = [0, 255];
		_trackBar.graphics.lineStyle();
		_trackBar.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
		_trackBar.graphics.drawRect(0, 0, _seekBar.width, _seekBar.height);
		_trackBar.graphics.endFill(  );
		
		_currentPlayTimeLabel.textColor = _controlColor;
		_currentPlayTimeLabel.y = _seekBar.height - (_trackBar.height/2)-(_currentPlayTimeLabel.height/2);
		
		_totalPlayTimeLabel.textColor = _controlColor;
		_totalPlayTimeLabel.x = _seekBar.width - _totalPlayTimeLabel.width;
		_totalPlayTimeLabel.y = _seekBar.height - (_trackBar.height / 2) - (_totalPlayTimeLabel.height / 2);
		
		drawDownloadProgress();
		
		_track.graphics.lineStyle(1, _controlColor);
		_track.graphics.beginFill(_darkColor, 0);
		_track.graphics.drawRect(_currentPlayTimeLabel.width, (_seekBar.height / 2) - (10 / 2), _seekBar.width - _currentPlayTimeLabel.width - _totalPlayTimeLabel.width, 10);
		_track.graphics.endFill();
		
		_thumb.graphics.lineStyle();
		_thumb.graphics.beginFill(_controlColor);
		_thumb.graphics.drawRect(_currentPlayTimeLabel.width, (_seekBar.height/2)-(10/2), 10, 10);
		_thumb.graphics.endFill();
	}
	
	/**
	 * Draws control bar player controls
	 */
	private function drawPlayingControls():Void
	{
		//Reset sprites for redraw
		_controlsBar.graphics.clear();
		_playControl.graphics.clear();
		_pauseControl.graphics.clear();
		_aspectRatioControl.graphics.clear();
		_fullscreenControl.graphics.clear();
		_volumeTrack.graphics.clear();
		_volumeIcon.graphics.clear();
		_volumeSlider.graphics.clear();
		
		//Draw controls bar
		var barWidth = 60;
		_controlsBar.x = (_stage.stageWidth - barWidth) + 20;
		_controlsBar.y = 25;
		
		var matrix:Matrix = new Matrix(  );
		matrix.createGradientBox(barWidth, _stage.stageHeight - 75, Utils.degreesToRadians(0), 0, _stage.stageHeight-75);
		var colors:Array<UInt> = [_brightColor, _darkColor];
		var alphas:Array<Float> = [0.75, 0.75];
		var ratios:Array<UInt> = [0, 255];
		_controlsBar.graphics.lineStyle();
		_controlsBar.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
		_controlsBar.graphics.drawRoundRect(0, 0, barWidth, _stage.stageHeight-75, 20, 20);
		_controlsBar.graphics.endFill();
		_controlsBar.width = barWidth;	
		_controlsBar.height = _stage.stageHeight - 75;
		
		var topMargin = 10;
		var barCenter:Float = (_controlsBar.width - 20) / 2;
		
		//Draw playbutton
		var triangleRatio = ((80 / 100) * (_controlsBar.width - 20));
		_playControl.x = barCenter - (triangleRatio/2);
		_playControl.y = topMargin;
		_playControl.graphics.lineStyle();
		_playControl.graphics.beginFill(_controlColor);
		Utils.drawTriangle(_playControl, 0, 0, triangleRatio, 0);
		_playControl.graphics.endFill();
		
		//Draw pausebutton
		_pauseControl.x = _playControl.x;
		_pauseControl.y = _playControl.y;
		_pauseControl.graphics.lineStyle();
		_pauseControl.graphics.beginFill(_controlColor);
		_pauseControl.graphics.drawRoundRect(0, 0, (33 / 100) * _playControl.width, _playControl.height, 6, 6);
		_pauseControl.graphics.drawRoundRect(_playControl.width - ((33 / 100) * _playControl.width), 0, (33 / 100) * _playControl.width, _playControl.height, 6, 6);
		_pauseControl.graphics.endFill();
		
		_pauseControl.graphics.lineStyle();
		_pauseControl.graphics.beginFill(_controlColor, 0);
		_pauseControl.graphics.drawRect(0, 0, _pauseControl.width, _playControl.height);
		_pauseControl.graphics.endFill();
		
		//Draw aspec ratio button
		_aspectRatioControl.x = _playControl.x;
		_aspectRatioControl.y = _playControl.y + _playControl.height + topMargin;
		_aspectRatioControl.graphics.lineStyle(2, _controlColor);
		_aspectRatioControl.graphics.drawRect(0, 0, _playControl.width, _playControl.height);
		
		_aspectRatioControl.graphics.lineStyle();
		_aspectRatioControl.graphics.beginFill(_controlColor, 1);
		_aspectRatioControl.graphics.drawRect(5, 5, _aspectRatioControl.width - 12, _aspectRatioControl.height - 12);
		_aspectRatioControl.graphics.endFill();
		
		_aspectRatioControl.graphics.lineStyle();
		_aspectRatioControl.graphics.beginFill(0x000000, 0);
		_aspectRatioControl.graphics.drawRect(0, 0, _aspectRatioControl.width, _aspectRatioControl.height);
		_aspectRatioControl.graphics.endFill();
		
		//Draw fullscreen button
		_fullscreenControl.x = _playControl.x;
		_fullscreenControl.y = _aspectRatioControl.y + _aspectRatioControl.height + topMargin;
		_fullscreenControl.graphics.lineStyle(2, _controlColor);
		_fullscreenControl.graphics.beginFill(0x000000, 0);
		_fullscreenControl.graphics.drawRoundRect(0, 0, _playControl.width, _playControl.height, 6, 6);
		_fullscreenControl.graphics.endFill();
		
		_fullscreenControl.graphics.lineStyle();
		_fullscreenControl.graphics.beginFill(_controlColor, 1);
		_fullscreenControl.graphics.drawRoundRect(3, 3, 4, 4, 2, 2);
		_fullscreenControl.graphics.drawRoundRect(_fullscreenControl.width - 9, 3, 4, 4, 2, 2);
		_fullscreenControl.graphics.drawRoundRect(3, _fullscreenControl.height - 9, 4, 4, 2, 2);
		_fullscreenControl.graphics.drawRoundRect(_fullscreenControl.width - 9, _fullscreenControl.height - 9, 4, 4, 2, 2);
		_fullscreenControl.graphics.endFill();
		
		//Draw volume icon
		_volumeIcon.x = _playControl.x;
		_volumeIcon.y = _controlsBar.height - _playControl.height - 10;
		_volumeIcon.graphics.lineStyle();
		_volumeIcon.graphics.beginFill(_controlColor, 1);
		_volumeIcon.graphics.drawRect(0, ((50 / 100) * _playControl.height) / 2, _playControl.width / 2, ((50 / 100) * _playControl.height));
		_volumeIcon.graphics.moveTo(_playControl.width / 2, ((50 / 100) * _playControl.height)/2);
		_volumeIcon.graphics.lineTo(_playControl.width, 0);
		_volumeIcon.graphics.lineTo(_playControl.width, _playControl.height);
		_volumeIcon.graphics.lineTo(_playControl.width / 2, ((50 / 100) * _playControl.height) + (((50 / 100) * _playControl.height) / 2));
		_volumeIcon.graphics.endFill();
		
		//Draw volume track
		_volumeTrack.x = _playControl.x;
		_volumeTrack.y = (_fullscreenControl.y + _fullscreenControl.height) + 10;
		_volumeTrack.graphics.lineStyle(1, _controlColor);
		_volumeTrack.graphics.beginFill(0x000000, 0);
		_volumeTrack.graphics.drawRect(0, 0, _playControl.width / 2, _volumeIcon.y - (_fullscreenControl.y + _fullscreenControl.height) - 20);
		_volumeTrack.graphics.endFill();
		_volumeTrack.x = barCenter - (_volumeTrack.width / 2);
		
		//Draw volume slider
		_volumeSlider.x = _volumeTrack.x;
		_volumeSlider.y = _volumeTrack.y;
		_volumeSlider.graphics.lineStyle();
		_volumeSlider.graphics.beginFill(_controlColor, 1);
		_volumeSlider.graphics.drawRect(0, 0, _volumeTrack.width, _volumeTrack.height);
		_volumeSlider.graphics.endFill();
		
	}
	//}
	
	
	//{Private Methods
	/**
	 * Hide de play controls bar
	 */
	private function hideControls():Void
	{
		if(_controlsBar.visible)
		{
			drawPlayingControls();	
			Animation.slideOut(_controlsBar, "right", 1500);
		}
	}
	
	/**
	 * Shows play controls bar
	 */
	private function showControls():Void
	{
		if(!_controlsBar.visible)
		{
			drawPlayingControls();	
			Animation.slideIn(_controlsBar, "right", 1500);
		}
	}
	//}
	
	
	//{Setters
	/**
	 * Sets the player colors and redraw them
	 * @param	colors Array of colors in the following order: darkColor, brightColor, controlColor, hoverColor
	 */
	public function setControlColors(colors:Array<String>):Void
	{
		_darkColor = colors[0].length > 0? Std.parseInt("0x" + colors[0]) : 0x000000;
		_brightColor = colors[1].length > 0? Std.parseInt("0x" + colors[1]) : 0x4c4c4c;
		_controlColor = colors[2].length > 0? Std.parseInt("0x" + colors[2]) : 0xFFFFFF;
		_hoverColor = colors[3].length > 0? Std.parseInt("0x" + colors[3]) : 0x67A8C1;
		
		var loaderColors:Array <String> = ["", "", "", ""];
		loaderColors[0] = colors[1];
		loaderColors[1] = colors[2];
		_loader.setColors(loaderColors);
		
		redrawControls();
	}
	//}
	
}