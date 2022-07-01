package;

import openfl.system.System;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var canLeave:Bool = false;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOverReal';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	var gasterVineBoom:FlxSprite;
	var gasterJumpscare:Int = 0;

	var music:FlxSound;
	var musicVolume:Float = 0.1;

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOverReal';
		endSoundName = 'gameOverEnd';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		PlayState.instance.setOnLuas('inGameOver', true);

		var sansCam:FlxCamera = new FlxCamera();
		sansCam.bgColor.alpha = 0;

		FlxG.cameras.reset(sansCam);
		FlxCamera.defaultCameras = [sansCam];

		Conductor.songPosition = 0;
		Conductor.changeBPM(97);

		switch(PlayState.curStage)
		{
			case 'ruins':
				var sansnoway:FlxSprite = new FlxSprite().loadGraphic(Paths.image('sansDeath'));
				sansnoway.scale.set(3, 3);
				sansnoway.screenCenter();
				sansnoway.cameras = [sansCam];
				sansnoway.alpha = 0.13;
				add(sansnoway);
			case 'void':
				deathSoundName = 'gaster/gaster_gameover' + FlxG.random.int(1, 11);
				gasterJumpscare = FlxG.random.int(41, 80);
		}
		
		if (gasterJumpscare == 69)
		{
			gasterVineBoom = new FlxSprite().loadGraphic(Paths.image('gasterDeath'));
			gasterVineBoom.scale.set(2.55, 2.55);
			gasterVineBoom.screenCenter();
			gasterVineBoom.cameras = [sansCam];
			gasterVineBoom.alpha = 0.18;
			gasterVineBoom.antialiasing = false;
			add(gasterVineBoom);
			deathSoundName = '';
			loopSoundName = 'smile';
			musicVolume = 1;
		}

		music = new FlxSound().loadEmbedded(Paths.music(loopSoundName), true);
		music.volume = musicVolume;
		FlxG.sound.list.add(music);
		if (deathSoundName != '')
		{
			FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.sound(deathSoundName), false, true, coolStartDeath));
			FlxG.sound.play(Paths.sound(deathSoundName), 1, false, null, true, coolStartDeath);	
		}
		music.play();

		if (deathSoundName == '' && gasterJumpscare != 69)
			coolStartDeath();
		else if (gasterJumpscare == 69)
		{
			new FlxTimer().start(11, function(tmr:FlxTimer){
				#if sys
				System.exit(0);
				#else
				leaveBullshit();
				#end
			});
		}

		PlayState.instance.boyfriend.startedDeath = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);

		if (gasterJumpscare != 69)
		{
			if (controls.ACCEPT)
			{
				endBullshit();
			}
		
			if (controls.BACK)
			{
				leaveBullshit();
			}
		}
		else if (gasterVineBoom != null)
		{
			gasterVineBoom.scale.set(gasterVineBoom.scale.x + 0.001, gasterVineBoom.scale.y + 0.001);
			gasterVineBoom.screenCenter();
		}

		if (music.playing)
		{
			Conductor.songPosition = music.time;
		}

		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	function coolStartDeath()
	{
		trace('coolStartDeath');
		music.fadeIn(7, 0.1, 1);
		canLeave = true;
	}

	var isEnding:Bool = false;
	function endBullshit():Void
	{
		if (!isEnding && canLeave)
		{
			isEnding = true;
			if (music.fadeTween.active)
				music.fadeTween.cancel();
			music.fadeOut(1.5, 0);
			new FlxTimer().start(1.6, function(tmr:FlxTimer)
			{
				music.stop();
				FlxG.sound.music.stop();
				MusicBeatState.resetState();
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}

	function leaveBullshit():Void
	{
		FlxG.sound.music.stop();
		PlayState.deathCounter = 0;
		PlayState.seenCutscene = false;
		
		if (PlayState.isStoryMode)
			MusicBeatState.switchState(new StoryMenuState());
		else
			MusicBeatState.switchState(new FreeplayState());
		
		FlxG.sound.playMusic(Paths.music('menuTheme'));
		PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
	}
}
