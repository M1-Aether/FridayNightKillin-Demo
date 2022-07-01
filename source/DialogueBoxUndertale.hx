package;

import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSubState;
import haxe.Json;
import haxe.format.JsonParser;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import openfl.utils.Assets;

using StringTools;

class DialogueBoxUndertale extends FlxSpriteGroup
{
	var dialogue:FlxTypeText;
	var dots:FlxTypeText;

	// var escapeText:FlxText;
	// var escapeTextTween:FlxTween;
	// var escapeTextFade:Bool = false;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;

	public var box:FlxSprite;
	public var character:FlxSprite;
	public var dialogueDelay:Float = 0.04;
	public var blackScreen:FlxSprite;

	public var isEnding:Bool = false;

	public var arrayText:Array<String> = [];
	public var arrayCharacters:Array<String> = [];

	public var curCharacter:String = "";

	public function new(curSong:String = '', ?song:String = null)
	{
		super();

		if (song == null || song.length <= 0)
			song = 'dialogueMusic';

		if(song != null && song != '') {
			FlxG.sound.playMusic(Paths.music(song), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.6);
		}

		setupText(curSong);
		curCharacter = arrayCharacters[0];

		blackScreen = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.width * 2, FlxColor.BLACK);
		blackScreen.screenCenter();
		add(blackScreen);

		box = new FlxSprite();
		box.frames = Paths.getSparrowAtlas('undertale-box');
		box.animation.addByPrefix('UTchara', 'undertale-box red0', 24, false);
		box.animation.addByPrefix('UTnormal', 'undertale-box white0', 24);
		box.animation.play('UTchara', true);
		box.scrollFactor.set();
		box.antialiasing = false;
		box.scale.set(1.4, 1.4);
		box.updateHitbox();
		box.screenCenter();
		box.y += 200;
		add(box);

		character = new FlxSprite().loadGraphic(Paths.image('dialogue/' + curCharacter));
		character.scrollFactor.set();
		character.antialiasing = false;
		character.setGraphicSize(Std.int(character.width * 1.4));
		character.updateHitbox();
		character.setPosition(box.x + 38, box.y + 40);
		add(character);

		dialogue = new FlxTypeText(box.x + 245, box.y + 42, 555, "");
		dialogue.scrollFactor.set();
		dialogue.setFormat(Paths.font('DTM-Mono.otf'), 27, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		dialogue.sounds = [FlxG.sound.load(Paths.sound('sansDialogue'), 0.6)];
		dialogue.antialiasing = false;
		add(dialogue);

		dots = new FlxTypeText(dialogue.x + 490, dialogue.y + 117, 80, '...');
		dots.scrollFactor.set();
		dots.setFormat(Paths.font('DTM-Mono.otf'), 35, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		dots.antialiasing = false;
		dots.waitTime = 2;
		dots.eraseCallback = function(){
			dots.start(0.45, true, true);
		};
		add(dots);

		// escapeText = new FlxText(box.x + 8, box.y - 20, 500, "Press ESC to skip the dialogue.");
		// escapeText.scrollFactor.set();
		// escapeText.setFormat(Paths.font('DTM-Mono.otf'), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// escapeText.antialiasing = false;
		// add(escapeText);

		// new FlxTimer().start(10, function(tmr:FlxTimer){
		// 	escapeTextFade = true;
		// });

		startDialogue();
	}

	var holdTime:Float = 0;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;
	override function update(elapsed:Float)
	{
		if (!isEnding)
		{
			// if (PlayerSettings.player1.controls.ACCEPT)
			if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
			{
				if (!dialogueEnded)
				{
					dialogue.skip();
				}
				else
				{
					startDialogue();
				}
			}
			else if (FlxG.keys.pressed.ENTER || FlxG.keys.pressed.SPACE)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					if (!dialogueEnded)
					{
						dialogue.skip();
					}
					else
					{
						startDialogue();
					}
				}
			}
			// else if (FlxG.keys.justPressed.ESCAPE)
			// {
			// 	endDialogue();
			// }
		}

		// if (escapeText.alpha > 0 && escapeTextFade)
		// 	escapeText.alpha -= 0.006;

		super.update(elapsed);
	}

	function startDialogue():Void
	{	
		if (dialogue != null && arrayText[0] != null)
		{
			dialogueStarted = true;
			dots.visible = false;

			changeCharacter();

			dialogue.resetText(arrayText.shift());
			dialogue.start(dialogueDelay, true);

			dialogueEnded = false;
			dialogue.completeCallback = function() {
				dialogueEnded = true;
				dots.visible = true;
				dots.start(0.45, true, true);
			};
		}
		else
		{
			endDialogue();
		}
		
		if(nextDialogueThing != null) {
			nextDialogueThing();
		}
	}

	function changeCharacter():Void
	{
		if (arrayCharacters[0] != null)
		{
			curCharacter = arrayCharacters.shift();
			character.loadGraphic(Paths.image('dialogue/' + curCharacter));

			switch(curCharacter)
			{
				case 'chara':
					dialogue.sounds = [FlxG.sound.load(Paths.sound('charaDialogue'), 0.6)];
					dialogueDelay = 0.042;
					box.animation.play('UTchara');
					dialogue.color = FlxColor.RED;
				default:
					dialogue.sounds = [FlxG.sound.load(Paths.sound('sansDialogue'), 0.6)];
					if (curCharacter == 'killer1')
						dialogueDelay = 0.069; // nice
					else
						dialogueDelay = 0.04;
					box.animation.play('UTnormal');
					dialogue.color = FlxColor.WHITE;
			}
			dots.color = dialogue.color;
		}
	}

	function endDialogue():Void
	{
		if (!isEnding)
		{
			isEnding = true;

			dots.visible = false;
			// escapeTextFade = true;

			if (FlxG.sound.music != null && FlxG.sound.music.playing)
				FlxG.sound.music.fadeOut(1.2, 0);

			FlxTween.tween(box, {alpha: 0}, 1);
			FlxTween.tween(character, {alpha: 0}, 1);
			FlxTween.tween(dialogue, {alpha: 0}, 1);

			FlxTween.tween(blackScreen, {alpha: 0}, 2.1, {startDelay: 1});

			new FlxTimer().start(3.2, function(tmr:FlxTimer)
			{
				finishThing();
				kill();
			});
		}
	}

	function setupText(curSong:String):Void
	{
		switch(curSong)
		{
			case 'the usual':
				arrayText = [
					"...",
					"It's so... quiet.",
					"I mean, yeah? Didn't you, like, slashed everyone in this place?",
					"You don't need to remind me...",
					"...",
					"...",
					"You know... Maybe we could do something about this graveyard-like silence?",
					"...Huh?",
					"Remember our little song before? It was rather fun... for me atleast, since you were bleeding all over the floor, hehe.",
					"...",
					"I-...",
					"What's wrong, comedian? Too lazy to do it again?",
					"..."
				];
				arrayCharacters = [
					'killer1',
					'killer1',
					'chara',
					'killer1',
					'chara',
					'killer1',
					'chara',
					'killer1',
					'chara',
					'killer1',
					'killer1',
					'chara',
					'killer1'
				];
			case 'know the deal':
				arrayText = [
					"Heh...",
					"Heheheh...",
					"..This isn't so bad after all.",
					"See? And here I thought you'd just go crying instead of singing.",
					"Riiight... Pretty bold for a ghost, aren't you, kid?",
					"Hmph. Yet I can still sing better than you, bone head.",
					"I am not done yet. And this time, you won't be so lucky."
					];
				arrayCharacters = [
					'killer2',
					'killer2',
					'killer2',
					'chara',
					'killer2',
					'chara',
					'killer2'
				];
			case 'know your place':
				arrayText = [
					"Nrghhh...",
					"How did you-..",
					"What's wrong, smiling trashbag? Losing your temper over silly songs?",
					"Hahaha! Aren't you just pathetic?",
					"Oh, you think you're so smart, huh?!",
					"Well it's time for you to regret your words, you punk!",
					"Ooooh, how scaaaary.",
					];
				arrayCharacters = [
					'killer3',
					'killer3',
					'chara',
					'chara',
					'killer3',
					'killer3',
					'chara'
				];
			default:
				arrayText = [
					'Default text =)'
				];
				arrayCharacters = [
					'chara'
				];
		}
	}
}
