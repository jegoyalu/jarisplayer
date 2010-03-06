/**
 * ...
 * @author Jefferson González
 */

package jaris.display;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.Lib;
import flash.net.URLRequest;

/**
 * To display an png, jpg or gif as preview of video content
 */
class Poster extends Sprite
{

	private var _stage:Stage;
	private var _movieClip:MovieClip;
	private var _loader:Loader;
	private var _source:String;
	private var _width:Float;
	private var _height:Float;
	private var _loading:Bool;
	private var _loaderStatus:jaris.display.Loader;
	
	public function new(source:String):Void
	{
		super();
		
		_stage = Lib.current.stage;
		_movieClip = Lib.current;
		_loader = new Loader();
		_source = source;
		_loading = true;
		
		//Reads flash vars
		var parameters:Dynamic<String> = flash.Lib.current.loaderInfo.parameters;
		
		//Draw Loader status
		var loaderColors:Array <String> = ["", "", "", ""];
		loaderColors[0] = parameters.brightcolor != null ? parameters.brightcolor : "";
		loaderColors[1] = parameters.controlcolor != null ? parameters.controlcolor : "";
		
		_loaderStatus = new jaris.display.Loader();
		_loaderStatus.setColors(loaderColors);
		addChild(_loaderStatus);
		
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
		_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onNotLoaded);
        _loader.load(new URLRequest(source));
	}
	
	/**
	 * Triggers when the poster image could not be loaded
	 * @param	event
	 */
	private function onNotLoaded(event:IOErrorEvent):Void
	{
		//Image not loaded
	}
	
	/**
	 * Triggers when the poster image finalized loading
	 * @param	event
	 */
	private function onLoaderComplete(event:Event):Void
	{
		_loaderStatus.visible = false;
		removeChild(_loaderStatus);
		
		addChild(_loader);
		
		_width = this.width;
		_height = this.height;
		_loading = false;
		
		_stage.addEventListener(Event.RESIZE, onStageResize);
		
		resizeImage();
	}
	
	/**
	 * Triggers when the stage is resized to resize the poster image
	 * @param	event
	 */
	private function onStageResize(event:Event):Void
	{
		resizeImage();
	}
	
	/**
	 * Resizes the poster image to take all the stage
	 */
	private function resizeImage():Void
	{
		this.height = _stage.stageHeight;
		this.width = ((_stage.stageWidth / _stage.stageHeight) * this.height);
		
		this.x = (_stage.stageWidth / 2) - (this.width / 2);
	}
	
	/**
	 * To check if the poster image stills loading
	 * @return true if stills loading false if loaded
	 */
	public function isLoading():Bool
	{
		return _loading;
	}
	
}