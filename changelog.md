Jaris FLV Player v2.0.17 - 22/11/2015

  * Disabled second parameter when calling play() on a rtmp source.
  * Disabled rtmpSourceParser() because it is causing issues.
  * Added rtmp notes to documentation.txt
  * fix new control do not autohide bug thanks to Michelangelo
  * fix new control vertical check thanks to Michelangelo

Jaris FLV Player v2.0.16 - 11/09/2014

  * Fixes in order to compile with new haxe v3 thanks to jonassmedegaard
  * Fix the AsyncErrorEvent exception thrown by player thanks to lcb931023
  * Added loadVideo() JsAPI call, call from JS new video thanks to Spiritdude
  * Added build.hxml

Jaris FLV Player v2.0.15 beta - 27/08/2011

  * New player controls
  * New flashvar controltype (0=old, 1=new) to indicate the which controls to use
  * New flashvar controlsize for new controls only
  * New flashvar seekcolor for new controls only
  * New flashvar buffertime to change the default 10 seconds buffer time for local/pseudo streaming
  * Bugfix on loader bar
  * All this changes thanks to Istvan Petres from http://jcore.net

Jaris FLV Player v2.0.14 beta - 20/05/2011

  * Removed some trace calls on youtube playback.

Jaris FLV Player v2.0.13 beta - 6/03/2011

  * Implemented loop class
  * Added loop functionality by passing loop=true or loop=1 as parameter
  * Fixed reported bug "slider will show wrong position" on pseudostreaming seek (Thanks to Adam)

Jaris FLV Player v2.0.12 beta - 06/11/2010

  * Java Script Api to listen for events and control the player.
  * More player events added to use on JSApi.
  * All this changes thanks to Sascha Kluger from http://projekktor.com

Jaris FLV Player v2.0.11 beta - 03/10/2010

  * Removed togglePlay of onFullscreen event since it seems that new flash versions doesnt emits
    the space keydown anymore that affected playback on fullcreen switching.
  * Added class to store user settings as volume and aspect ratio to load them next time player is load.

Jaris FLV Player v2.0.10 beta - 29/09/2010

  * Added flashvar aspectratio option to initially tell on wich aspect ratio to play the video

Jaris FLV Player v2.0.9 beta - 26/05/2010

  * Improved poster to keep aspect ratio and display back when playback finishes

Jaris FLV Player v2.0.8 beta - 14/05/2010

  * Fixed bug on formatTime function calculating hours as minutes

Jaris FLV Player v2.0.7 beta - 03/19/2010

  * Fixed youtube security bug

Jaris FLV Player v2.0.6 beta - 03/13/2010

  * Added: display current aspect ratio label on aspect ratio toggle
  * Improved readability of text
  * only attach netstream to video object if input type is video
  * remove poster from player code

Jaris FLV Player v2.0.5 beta - 03/12/2010

  * Improved aspect ratio toogle when video aspect ratio is already on the aspect ratios list
  * Fixed context menu aspect ratio rotation

Jaris FLV Player v2.0.4 beta - 03/11/2010

  * Fixed a drawing issue where seek bar after fullscreen stayed long
  * Documented other parts of the code

Jaris FLV Player v2.0.3 beta - 03/10/2010

  * Support for rtmp streaming
  * support for youtube
  * better support for http streaming like lighttpd
  * Fixed calculation of width on original aspect ratio larger than stage
  * And many hours of improvements

Jaris FLV Player v2.0.2 beta - 03/09/2010

  * Implement EventDispatcher on Player class instead of using custom event mechanism
  * Fixed not getting initial stage widht and height on IE when using swfobjects
  * Some more improvements to controls on short heights
  * Other improvements and code refactoring
  * added id3 info to player events

Jaris FLV Player v2.0.1 beta - 03/08/2010

  * Toggle Quality on Context Menu
  * Introduction of type parameter
  * Initial mp3 support
  * Loader fixes
  * Controls fixes
  * Other refinements and fixes
  * Duration parameter to indicate how much total time takes input media

Jaris FLV Player v2.0.0 beta - 03/05/2010

  * Moved from swishmax 2 to haxe and flashdevelop
  * New GUI completely written in haxe (AS3)
  * Hide controls on fullscreen
  * Recalculate aspect ratio on fullscreen.
  * Redraw controls on fullscreen and normal switching.
  * Initial pseudo streaming support
  * Compiled to flash 10
  * Now uses as3 libraries
  * Optional Hardware scaling
  * Video smoothing enabled by default
  * Added custom context menu
  * Other refinements and fixes

Jaris FLV Player v1.0 - 05/21/2008

  * Calculates video aspect ratio on player load.
  * Support Flash 9 Stage.displayState (Fullscreen mode).
  * Support for preview image of the video.
  * Display buffering message.
  * Internal volume control.
  * Back and forward control.
  * Display the actual playing time and total time.
  * Support for logo image on the fly.
  * Flag to autostart the video on player load.
