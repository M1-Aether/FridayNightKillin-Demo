package;

import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class StorySelectionState extends MusicBeatState
{
	public var curSelected:Int = 0;

	var storyItems:FlxTypedGroup<FlxSprite>;
	
	var optionShit:Array<String> = [
		'prequel',
		'present'
	];

	var gasterWeekUnlocked:Bool = false;

	override function create()
	{
		persistentUpdate = persistentDraw = true;

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		WeekData.reloadWeekFiles(true);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		storyItems = new FlxTypedGroup<FlxSprite>();
		add(storyItems);

		if (StoryMenuState.weekCompleted.get('weekPrequel1') && StoryMenuState.weekCompleted.get('weekPresent1'))
		{
			optionShit.push('gaster');
			gasterWeekUnlocked = true;
		}

		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/
		var offset:Int = -400;

		for (i in 0...optionShit.length)
		{
			var storyItem:FlxSprite = new FlxSprite(50, 0);
			storyItem.scale.set(0.7, 0.7);
			storyItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			storyItem.animation.addByPrefix('idle', optionShit[i] + " white", 24);
			storyItem.animation.addByPrefix('selected', optionShit[i] + " yellow", 24);
			storyItem.animation.play('idle');
			storyItem.updateHitbox();
			storyItem.screenCenter();
			storyItem.x += offset;
			if (i == 2)
			{
				storyItem.screenCenter();
				storyItem.y += 250;
				storyItem.alpha = 0.2;
			}
			storyItem.scrollFactor.set();
			storyItem.antialiasing = ClientPrefs.globalAntialiasing;
			storyItem.ID = i;
			storyItems.add(storyItem);
			offset = -offset;
		}

		changeItem(0, false);

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P && curSelected != 2)
			{
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P && curSelected != 2)
			{
				changeItem(1);
			}

			if (gasterWeekUnlocked && controls.UI_UP_P && curSelected == 2)
			{
				changeItem(1);
			}

			if (gasterWeekUnlocked && controls.UI_DOWN_P && curSelected != 2)
			{
				changeItem(789654123);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

			if (controls.ACCEPT && curSelected < 2)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				storyItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							MusicBeatState.switchState(new StoryMenuState());
						});
					}
				});
			}
			else if (controls.ACCEPT && curSelected == 2)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				selectWeek();

				storyItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							LoadingState.loadAndSwitchState(new PlayState(), true);
						});
					}
				});
			}
		}
		super.update(elapsed);
	}

	function changeItem(huh:Int = 0, ?playSound = true)
	{
		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += huh;

		if (!gasterWeekUnlocked && curSelected >= storyItems.length)
			curSelected = 0;
		else if (gasterWeekUnlocked && curSelected >= storyItems.length - 1)
			curSelected = 0;

		if (!gasterWeekUnlocked && curSelected < 0)
			curSelected = storyItems.length - 1;
		else if (gasterWeekUnlocked && curSelected < 0)
			curSelected = storyItems.length - 2;

		if (huh == 789654123)
			curSelected = 2;

		switch(curSelected)
		{
			case 0:
				StoryMenuState.storySelection = 'Prequel';
			case 1:
				StoryMenuState.storySelection = 'Present';
			case 2:
				StoryMenuState.storySelection = 'Gaster';
		}

		storyItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				spr.updateHitbox();
			}
		});
	}

	function selectWeek()
	{
		var realWeek = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			if (WeekData.weeksList[i].startsWith("weekGaster"))
			{
				break;
			}
			realWeek++;
		}

		PlayState.storyWeek = realWeek;

		PlayState.storyPlaylist = [
			"Voided"
		];
		PlayState.isStoryMode = true;

		PlayState.storyDifficulty = 1;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-hard', PlayState.storyPlaylist[0].toLowerCase());
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;
	}
}
