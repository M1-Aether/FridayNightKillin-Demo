package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class PauseItem extends FlxSprite
{
	public var targetY:Float = 0;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public function new(x:Float, y:Float, itemName:String = '')
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('pause/' + Paths.formatToSongPath(itemName));
		animation.addByPrefix('selected', itemName + " selected", 1, false);
		animation.addByPrefix('normal', itemName + " normal", 1, false);
		animation.play('normal');
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
		y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);
	}
}
