package;

import flixel.system.FlxSound;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;

class WeekEndState extends MusicBeatState
{

	override function create()
	{
		var sound:FlxSound = new FlxSound();
		var bg:FlxSprite = new FlxSprite();
		if (StoryMenuState.storySelection == "Present")
		{
			bg.loadGraphic(Paths.image('weekUnlocked/weekGaster'));
			sound.loadEmbedded(Paths.sound('gasterUnlocked'));
		}
		else
		{
			bg.loadGraphic(Paths.image('weekUnlocked/weekPresent'));
		}
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 0.8));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		if (StoryMenuState.storySelection == "Present")
			sound.play();
		
		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (!selectedSomethin && controls.ACCEPT)
		{
			selectedSomethin = true;
			FlxG.sound.playMusic(Paths.music('menuTheme'));
			MusicBeatState.switchState(new StoryMenuState());
		}

		super.update(elapsed);
	}
}
