package;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef HealthIconFile = {
	var animations:Array<AnimationArray>;
	var scale:Float;
	var no_antialiasing:Bool;
}

typedef AnimationArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var alphaTracker:FlxSprite;
	public var trackAlpha:Bool = true;
	public var isAnimated:Bool = false;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public var animOffsets:Map<String, Array<Dynamic>>;
	public var offsets:Array<Float> = [0, 0];
	public var animationsArray:Array<AnimationArray> = [];

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end

		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
		if (alphaTracker != null && trackAlpha)
			alpha = alphaTracker.alpha;
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/icon-' + char;

			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modsXml(name))) {
				isAnimated = true;
			}
			else 
			#end
			if (Paths.fileExists('images/' + name + '.xml', TEXT) && Paths.fileExists('images/' + name + '.png', IMAGE)) {
				isAnimated = true;
			}
			else {
				isAnimated = false;
			}

			if (!isAnimated)
			{
				if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
				if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
				var file:Dynamic = Paths.image(name);

				loadGraphic(file); //Load stupidly first for getting the file size
				loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); //Then load it fr
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
				updateHitbox();

				animation.add(char, [0, 1], 0, false, isPlayer);

				animation.play(char);
			}
			else
			{
				var iconPath:String = 'images/icons/icon-';
				#if MODS_ALLOWED
				var path:String = Paths.modFolders(iconPath + char + '.json');
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(iconPath + char + '.json');
				}

				if (!FileSystem.exists(path))
				#else
				var path:String = Paths.getPreloadPath(iconPath + char + '.json');
				if (!Assets.exists(path))
				#end
				{
					path = Paths.getPreloadPath(iconPath + 'gaster.json');
				}

				#if MODS_ALLOWED
				var rawJson = File.getContent(path);
				#else
				var rawJson = Assets.getText(path);
				#end
				var json:HealthIconFile = cast Json.parse(rawJson);
				frames = Paths.getSparrowAtlas(name);
				if(json.scale != 1) {
					// jsonScale = json.scale;
					setGraphicSize(Std.int(width * json.scale));
					updateHitbox();
				}
				if(json.no_antialiasing || !ClientPrefs.globalAntialiasing)
				{
					antialiasing = false;
				}
				animationsArray = json.animations;
				if(animationsArray != null && animationsArray.length > 0)
				{
					for (anim in animationsArray)
					{
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = !!anim.loop;
						var animIndices:Array<Int> = anim.indices;
						if(animIndices != null && animIndices.length > 0) {
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
							trace('icon anim ADDED ! byIndices : ' + animAnim + ', ' + animName + ', ' + animIndices + ', ' + animFps + ', ' + animLoop);
						} else {
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
							trace('icon anim ADDED ! byPrefix : ' + animAnim + ', ' + animName + ', ' + animFps + ', ' + animLoop);
						}

						if(anim.offsets != null && anim.offsets.length > 1) {
							addOffset(anim.anim, -anim.offsets[0], -anim.offsets[1]);
						}
					}
				}
				else
				{
					animation.addByPrefix(char + '-normal', 'icon-' + char + ' normal', 24, false);
				}

				playAnim(char + '-normal');
			}

			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		if (!isAnimated)
		{
			offset.x = iconOffsets[0];
			offset.y = iconOffsets[1];
		}
	}

	public function getCharacter():String {
		return char;
	}

	public function playAnim(anim:String):Void
	{
		// animation.play(AnimName, Force, Reversed, Frame);
		animation.play(anim);

		var daOffset = animOffsets.get(anim);
		if (animOffsets.exists(anim))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
