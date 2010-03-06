/**
 * ...
 * @author Jefferson González
 */

package jaris.display;

import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.URLRequest;

/**
 * To display an image in jpg, png or gif format as logo
 */
class Logo extends Sprite
{
	private var _stage:Stage;
	private var _movieClip:MovieClip;
	private var _loader:Loader;
	private var _position:String;
	private var _alpha:Float;
	private var _source:String;
	private var _width:Float;
	private var _link:String;
	private var _loading:Bool;
	
	public function new(source:String, position:String, alpha:Float, width:Float=0.0) 
	{
		super();
		
		_stage = Lib.current.stage;
		_movieClip = Lib.current;
		_loader = new Loader();
		_position = position;
		_alpha = alpha;
		_source = source;
		_width = width;
		_loading = true;
		
		this.tabEnabled = false;
		
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
		_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onNotLoaded);
        _loader.load(new URLRequest(source));
	}
	
	/**
	 * Triggers when the logo image could not be loaded
	 * @param	event
	 */
	private function onNotLoaded(event:IOErrorEvent):Void
	{
		//Image not loaded
	}
	
	/**
	 * Triggers when the logo image finished loading.
	 * @param	event
	 */
	private function onLoaderComplete(event:Event)
	{
		addChild(_loader);
		
		setWidth(_width);
		setPosition(_position);
		setAlpha(_alpha);
		_loading = false;
		
		_stage.addEventListener(Event.RESIZE, onStageResize);
	}
	
	/**
	 * Recalculate logo position on stage resize
	 * @param	event
	 */
	private function onStageResize(event:Event)
	{
		setPosition(_position);
	}
	
	/**
	 * Opens the an url when the logo is clicked
	 * @param	event
	 */
	private function onLogoClick(event:MouseEvent)
	{
		Lib.getURL(new URLRequest(_link), "_blank");
	}
	
	/**
	 * Position where logo will be showing
	 * @param	position values could be top left, top right, bottom left, bottom right
	 */
	public function setPosition(position:String)
	{
		switch(position)
		{
			case "top left":
				this.x = 25;
				this.y = 25;
			
			case "top right":
				this.x = _stage.stageWidth - this._width - 25;
				this.y = 25;
			
			case "bottom left":
				this.x = 25;
				this.y = _stage.stageHeight - this.height - 25;
			
			case "bottom right":
				this.x = _stage.stageWidth - this.width - 25;
				this.y = _stage.stageHeight - this.height - 25;
				
			default: 
				this.x = 25;
				this.y = 25;
		}
	}
	
	/**
	 * To set logo transparency
	 * @param	alpha
	 */
	public function setAlpha(alpha:Float)
	{
		this.alpha = alpha;
	}
	
	/**
	 * Sets logo width and recalculates height keeping aspect ratio
	 * @param	width
	 */
	public function setWidth(width:Float) 
	{
		if (width > 0)
		{
			this.height = (this.height / this.width) * width;
			this.width = width;
		}
	}
	
	/**
	 * Link that opens when clicked the logo image is clicked
	 * @param	link
	 */
	public function setLink(link:String)
	{
		_link = link;
		this.buttonMode = true;
		this.useHandCursor = true;
		this.addEventListener(MouseEvent.CLICK, onLogoClick);
	}
	
	/**
	 * To check if the logo stills loading
	 * @return true if loading false otherwise
	 */
	public function isLoading():Bool
	{
		return _loading;
	}
}