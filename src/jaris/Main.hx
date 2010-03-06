/**
 * ...
 * @author Jefferson González
 * 
 */

package jaris;

import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import flash.system.Capabilities;
import jaris.display.Loader;
import jaris.display.Logo;
import jaris.display.Menu;
import jaris.display.Poster;
import jaris.player.Controls;
import jaris.player.Player;
import jaris.player.StreamType;

/**
 * Main jaris player starting point
 */
class Main 
{
	static function main() 
	{
		//Initialize stage and main movie clip
		var stage = Lib.current.stage;
		var movieClip = Lib.current;
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		//Reads flash vars
		var parameters:Dynamic<String> = flash.Lib.current.loaderInfo.parameters;
		
		//Draw preview image
		var poster:String = parameters.poster != null ? parameters.poster : "";
		var posterImage = new Poster(poster);
		movieClip.addChild(posterImage);
		
		//Initialize and draw player object
		var player:Player = new Player();
		if (Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX")
		{
			var autoStart:Bool = parameters.autostart == "true" || parameters.autostart == ""? true: false;
			var streamType:String = parameters.streamtype != ""? parameters.streamtype : StreamType.FILE;
			
			player.setStreamType(streamType);
			
			if (autoStart)
			{
				player.load(parameters.file);
			}
			else
			{
				player.setVideoSource(parameters.file);
			}
			
			player.setPoster(posterImage);
			player.setHardwareScaling(parameters.hardwarescaling=="true"?true:false);
		}
		else
		{
			//For development purpose
			player.load("jaris-intro.mp4");
		}
		
		//Modify Context Menu
		var menu:Menu = new Menu(player);
		
		//Draw logo
		var logoSource:String = parameters.logo != null ? parameters.logo : "logo.png";
		var logoPosition:String = parameters.logoposition != null ? parameters.logoposition : "top left";
		var logoAlpha:Float = parameters.logoalpha != null ? Std.parseFloat(parameters.logoalpha) / 100 : 0.3;
		var logoWidth:Float = parameters.logowidth != null ? Std.parseFloat(parameters.logowidth) : 130;
		var logoLink:String = parameters.logolink != null ? parameters.logolink : "http://jaris.sourceforge.net";
		
		var logo:Logo = new Logo(logoSource, logoPosition, logoAlpha, logoWidth);
		logo.setLink(logoLink);
		movieClip.addChild(logo);
		
		
		//Draw Controls
		var controls:Controls = new Controls(player);
		
		var controlColors:Array <String> = ["", "", "", ""];
		controlColors[0] = parameters.darkcolor != null ? parameters.darkcolor : "";
		controlColors[1] = parameters.brightcolor != null ? parameters.brightcolor : "";
		controlColors[2] = parameters.controlcolor != null ? parameters.controlcolor : "";
		controlColors[3] = parameters.hovercolor != null ? parameters.hovercolor : "";
		
		controls.setControlColors(controlColors);
		
		movieClip.addChild(controls);
	}
}