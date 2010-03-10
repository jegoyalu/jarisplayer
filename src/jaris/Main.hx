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


package jaris;

import flash.display.MovieClip;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flash.system.Capabilities;
import jaris.display.Logo;
import jaris.display.Menu;
import jaris.display.Poster;
import jaris.player.controls.Controls;
import jaris.player.InputType;
import jaris.player.Player;
import jaris.player.StreamType;

/**
 * Main jaris player starting point
 */
class Main 
{
	static var stage:Stage;
	static var movieClip:MovieClip;
	
	static function main():Void
	{
		//Initialize stage and main movie clip
		stage = Lib.current.stage;
		movieClip = Lib.current;
		
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
			var autoStart:Bool = parameters.autostart == "true" || parameters.autostart == "" || parameters.autostart == null? true: false;
			var type:String = parameters.type != "" && parameters.type != null? parameters.type : InputType.VIDEO;
			var streamType:String = parameters.streamtype != "" && parameters.streamtype != null? parameters.streamtype : StreamType.FILE;
			
			player.setType(type);
			player.setStreamType(streamType);
			
			if (autoStart)
			{
				player.load(parameters.file, type, streamType);
			}
			else
			{
				player.setSource(parameters.file);
			}
			
			player.setPoster(posterImage);
			player.setHardwareScaling(parameters.hardwarescaling=="true"?true:false);
		}
		else
		{
			//For development purposes
			//player.load("http://jaris.sourceforge.net/files/jaris-intro.flv", InputType.VIDEO, StreamType.FILE);
			player.load("http://jaris.sourceforge.net/files/audio.mp3", InputType.AUDIO, StreamType.FILE);
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
		var duration:String = parameters.duration != "" && parameters.duration != null? parameters.duration : "0";
		var controls:Controls = new Controls(player);
		
		var controlColors:Array <String> = ["", "", "", ""];
		controlColors[0] = parameters.darkcolor != null ? parameters.darkcolor : "";
		controlColors[1] = parameters.brightcolor != null ? parameters.brightcolor : "";
		controlColors[2] = parameters.controlcolor != null ? parameters.controlcolor : "";
		controlColors[3] = parameters.hovercolor != null ? parameters.hovercolor : "";
		
		controls.setDurationLabel(duration);
		controls.setControlColors(controlColors);
		
		movieClip.addChild(controls);
	}
}