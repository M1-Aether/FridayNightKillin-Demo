package;

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

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.2h'; // This is also used for Discord RPC
	public static var modVersion:String = '1.1';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var killerSans:FlxSprite;

	var optionShit:Array<String> = ['story_mode', 'freeplay', 'settings', 'credits'];

	// var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/bg'));
		bg.scrollFactor.set();
		// bg.setGraphicSize(Std.int(bg.width * 1.175));
		// bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite();
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter();
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
		}

		killerSans = new FlxSprite();
		killerSans.frames = Paths.getSparrowAtlas('mainmenu/k_sans_log');
		killerSans.animation.addByPrefix('idle', 'balls sans intro0', 24, false);
		killerSans.animation.play('idle');
		killerSans.scrollFactor.set();
		killerSans.screenCenter();
		killerSans.x += 240;
		killerSans.y += 145;
		add(killerSans);

		var overlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mainmenu/overlay'));
		overlay.scrollFactor.set();
		overlay.screenCenter();
		add(overlay);

		FlxG.camera.follow(camFollowPos, null, 1);

		#if debug
		var debugShit:FlxText = new FlxText(0, FlxG.height - 84, 0, "DEBUG BUILD", 12);
		debugShit.scrollFactor.set();
		debugShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugShit.x = (FlxG.width - debugShit.width) - 12;
		add(debugShit);
		#end

		var modVersionShit:FlxText = new FlxText(0, FlxG.height - 64, 0, "Friday Night Killin' DEMO v" + modVersion);
		modVersionShit.scrollFactor.set();
		modVersionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		modVersionShit.x = (FlxG.width - modVersionShit.width) - 12;
		add(modVersionShit);
		var psychVersionShit:FlxText = new FlxText(0, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion);
		psychVersionShit.scrollFactor.set();
		psychVersionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		psychVersionShit.x = (FlxG.width - psychVersionShit.width) - 12;
		add(psychVersionShit);
		var fnfVersionShit:FlxText = new FlxText(0, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'));
		fnfVersionShit.scrollFactor.set();
		fnfVersionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fnfVersionShit.x = (FlxG.width - fnfVersionShit.width) - 12;
		add(fnfVersionShit);

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		trace('achievements');
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
		{
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2]))
			{ // It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		trace(StoryMenuState.weekCompleted);

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement()
	{
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P && curSelected > 0 && curSelected < 3)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P && curSelected < 2)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.UI_RIGHT_P && curSelected != 3)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(69);
			}

			if (controls.UI_LEFT_P && curSelected == 3)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				menuItems.forEach(function(spr:FlxSprite)
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
							var daChoice:String = optionShit[curSelected];
							switch (daChoice)
							{
								case 'story_mode':
									MusicBeatState.switchState(new StorySelectionState());
								case 'freeplay':
									MusicBeatState.switchState(new FreeplayState());
								case 'credits':
									MusicBeatState.switchState(new CreditsState());
								case 'settings':
									LoadingState.loadAndSwitchState(new options.OptionsState());
							}
						});
					}
				});
			}
		}
		#if desktop
		if (FlxG.keys.anyJustPressed(debugKeys))
		{
			selectedSomethin = true;
			MusicBeatState.switchState(new MasterEditorMenu());
		}
		#end

		super.update(elapsed);
	}

	override function stepHit():Void
	{
		if (killerSans != null && curStep % 2 == 0)
			killerSans.animation.play('idle');
		super.beatHit();
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0 || huh == 69)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.centerOffsets();
			}
		});
	}
}
