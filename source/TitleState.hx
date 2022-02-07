package;

import flixel.addons.plugin.control.FlxControl;
import flixel.group.FlxSpriteGroup;
import sys.io.File;
import com.akifox.asynchttp.HttpResponse;
import com.akifox.asynchttp.HttpRequest;
import sys.FileSystem;
import haxe.Exception;
import haxe.Json;
import haxe.Http;
import EngineSettings.Settings;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
#if newgrounds
import io.newgrounds.NG;
#end
import lime.app.Application;
import openfl.Assets;

using StringTools;

typedef TitleScreen = {
	var script:Script;
	var grp:FlxSpriteGroup;
}
class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var updateAlphabet:Alphabet;
	var updateIcon:FlxSprite;
	var updateRibbon:FlxSprite;
	public static var skipOldSkinCheck = false;


	override public function create():Void
	{
		trace(FlxControls.pressed);

		if (!skipOldSkinCheck) {
			if (FileSystem.exists(Paths.getOldSkinsPath())) {
				FlxG.switchState(new OutdatedSkinsScreen(new TransitionData(TransitionType.NONE), new TransitionData(TransitionType.NONE)));
			}
		}
		trace(54);
		#if polymod
			#if sourceCode
			// Polymod.init({modRoot: "./", dirs: ['mods']}); //poggers
			#else
			// Polymod.init({modRoot: "./", dirs: ['mods']}); //poggers
			#end
		#end

		trace("PlayerSettings");
		PlayerSettings.init();

		trace("curWacky");
		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		trace("super.create()");
		super.create();

		// NGio .noLogin(APIStuff.API);

		#if ng
		var ng:// NGio  = new // NGio (APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end



		// Copy default files


		// trace("CoolUtil.copyFolder");
		// #if sys
		// 	// Copies the skin folder
		// 	#if windows
		// 		CoolUtil.copyFolder("skins/", Paths.getSkinsPath());
		// 	#else
		// 		CoolUtil.copyFolder("./skins/", Paths.getSkinsPath());
		// 	#end
		// #end
		
		trace("Highscore.load");
		Highscore.load();
		#if web
			trace("Loading characters library");
			Assets.loadLibrary("characters");
		#end

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			// if (StoryMenuState.weekUnlocked.length < 4)
			// 	StoryMenuState.weekUnlocked.insert(0, true);

			// // QUICK PATCH OOPS!
			// if (!StoryMenuState.weekUnlocked[0])
			// 	StoryMenuState.weekUnlocked[0] = true;
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState_New());
		#else
		
		trace("FlxTimer");
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end

		#if desktop
		trace("DiscordClient");
		DiscordClient.initialize();
		
		trace("Application.current.onExit");
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		});
		
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	var titleScreens:Array<TitleScreen>;
	var activeTitleScreen = -1;

	var isInTransition = false;

	function switchTitleScreen() {
		if (isInTransition) return;
		if (titleScreens.length < 2) {
			if (activeTitleScreen == -1) {
				activeTitleScreen = 0;
				var grp = titleScreens[activeTitleScreen].grp;
				grp.y = 0;
				insert(members.indexOf(titleText), grp);

			}
			return;
		}

		isInTransition = true;
		var max = titleScreens.length - 1;
		if (activeTitleScreen > -1) max -= 1;
		var randomNumber = FlxG.random.int(0, max);
		if (activeTitleScreen > -1)
			if (randomNumber >= activeTitleScreen)
				randomNumber++;
		
		function onFinish(randomNumber:Int) {
			activeTitleScreen = randomNumber;
			trace(randomNumber);
			var grp = titleScreens[activeTitleScreen].grp;
			grp.y = FlxG.height;
			FlxTween.tween(grp, {y: 0}, Conductor.crochet / 500, {ease: FlxEase.quintOut, onComplete: function(t2) {
				isInTransition = false;
			}});
			insert(members.indexOf(titleText), grp);
		}

		if (activeTitleScreen == -1) {
			onFinish(randomNumber);
		} else {
			FlxTween.tween(titleScreens[activeTitleScreen].grp, {y: FlxG.height}, Conductor.crochet / 500, {ease: FlxEase.quintIn, onComplete: function(t) {
				remove(titleScreens[activeTitleScreen].grp);
				onFinish(randomNumber);
			}});
		}
	}
	function startIntro()
	{
		if (!initialized)
		{
			

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);
		
		titleScreens = [];
		var keys = ModSupport.modConfig.keys();
		while(keys.hasNext()) {
			var k = keys.next();
			var path = '${Paths.modsPath}/$k/data';
			if (FileSystem.exists(path) && FileSystem.isDirectory(path)) {
				var script = Script.create('$path/titlescreen');
				if (script != null) {
					var spriteGrp = new FlxSpriteGroup(0, 0);
					ModSupport.setScriptDefaultVars(script, k, {});
					script.setVariable("create", function() {});
					script.setVariable("beatHit", function() {});
					script.setVariable("add", spriteGrp.add);
					script.loadFile('$path/titlescreen');
					script.executeFunc("create");
					titleScreens.push({
						script: script,
						grp: spriteGrp
					});
				}
			}
		}

		// logoBl = new FlxSprite(-50, -35);
		// logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		// logoBl.antialiasing = true;
		// logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		// logoBl.animation.play('bump');
		// logoBl.updateHitbox();
		// logoBl.scale.x = logoBl.scale.y = 0.95;
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		// gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		// gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		// gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		// gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		// gfDance.antialiasing = true;
		// add(gfDance);
		// add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#if android
			titleText.animation.addByPrefix('idle', "Android_Idle", 24);
			titleText.animation.addByPrefix('press', "Android_Press", 24);
		#else
			titleText.animation.addByPrefix('idle', "Windows_Idle", 24);
			titleText.animation.addByPrefix('press', "Windows_Press", 24);
		#end
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = true;
		
		updateRibbon = new FlxSprite(0, FlxG.height - 75).makeGraphic(FlxG.width, 75, 0x88000000);
		updateRibbon.visible = false;
		updateRibbon.alpha = 0;
		add(updateRibbon);

		updateIcon = new FlxSprite(FlxG.width - 75, FlxG.height - 75);
		updateIcon.frames = Paths.getSparrowAtlas("pauseAlt/bfLol", "shared");
		updateIcon.animation.addByPrefix("dance", "funnyThing instance 1", 20, true);
		updateIcon.animation.play("dance");
		updateIcon.setGraphicSize(65);
		updateIcon.updateHitbox();
		updateIcon.antialiasing = true;
		updateIcon.visible = false;
		add(updateIcon);

		updateAlphabet = new Alphabet(0, 0, "Checking for updates...", false, false, FlxColor.WHITE);
		for(c in updateAlphabet.members) {
			c.scale.x /= 2;
			c.scale.y /= 2;
			c.updateHitbox();
			c.x /= 2;
			c.y /= 2;
		}
		updateAlphabet.visible = false;
		updateAlphabet.x = updateIcon.x - updateAlphabet.width - 10;
		updateAlphabet.y = updateIcon.y;
		add(updateAlphabet);
		updateIcon.y += 15;
		

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var introText:Array<Array<String>> = [];

		var keys = ModSupport.modConfig.keys();
		while(keys.hasNext()) {
			var k = keys.next();
			var path = '${Paths.modsPath}/$k/data/introText.txt';
			if (FileSystem.exists(path)) {
				var fContent = File.getContent(path);
				for(l in fContent.split("\n")) if (l.trim() != "" && l.indexOf("--") != -1) introText.push(l.split("--"));
			}
		}

		if (introText.length == 0) introText = [["the intro text", "where did it go"]];

		return introText;
		// var fullText:String = Assets.getText(Paths.txt('introText'));

		// var firstArray:Array<String> = fullText.split('\n');
		// var swagGoodArray:Array<Array<String>> = [];

		// for (i in firstArray)
		// {
		// 	swagGoodArray.push(i.split('--'));
		// }

		// return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (updateRibbon != null) {
			updateRibbon.alpha = Math.min(1, updateRibbon.alpha + (elapsed / 0.2));
		}
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxControls.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxControls.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			#if !switch
			// NGio .unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				// NGio .unlockMedal(61034);
			#end

			if (titleText != null) titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			#if testCrash
			var lolCrash:Void->Void = null;
			lolCrash();
			#end
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Check if version is outdated
				var request = new HttpRequest({
					url: #if pastebinTest
					"https://pastebin.com/raw/rtVtsaiB"
					#elseif timeoutTest
					"http://10.255.255.1/test"
					#else
					"https://raw.githubusercontent.com/YoshiCrafter29/YoshiEngine/main/update.json"
					#end,
					async: true,
					callback: function(response:HttpResponse) {
						updateIcon.visible = false;
						updateAlphabet.visible = false;
						updateRibbon.visible = false;
						if (response.isOK) {
							onUpdateData(response.content);
						} else {
							trace(response.status);
							FlxG.switchState(new MainMenuState());
						}
					}
				});
				updateIcon.visible = true;
				updateAlphabet.visible = true;
				updateRibbon.visible = true;
				updateRibbon.alpha = 0;
				request.send();
				
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		try {
			super.update(elapsed);
		} catch(e) {
			
		}
	}

	function onUpdateData(data:String) {
		// var version:String = "v" + Application.current.meta.get('version');
		var jsonData:YoshiEngineVersion = Json.parse(data.trim());
		var outDated = false;
		var amount = jsonData.version.length;
		if (Main.engineVer.length > amount) amount = Main.engineVer.length;
		for(i in 0...amount) {
			var latestVer = 0;
			var localVer = 0;
			if (i < Main.engineVer.length)
				localVer = Main.engineVer[i];
			if (i < jsonData.version.length)
				latestVer = jsonData.version[i];

			if (localVer < latestVer) {
				outDated = true;
				break;
			} else if (latestVer < localVer) {
				break;
			}
		}
		if (outDated)
		{
			FlxG.switchState(new OutdatedSubState(jsonData));
			// trace('OLD VERSION!');
			// trace('old ver');
			// trace(version.trim());
			// trace('cur ver');
			//trace( NGio .GAME_VER_NUMS.trim());
		}
		else
		{

			FlxG.switchState(new MainMenuState());
		}
	}
	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	var skipBeat:Int = 0;

	override function beatHit()
	{
		super.beatHit();

		if (skippedIntro) {
			if (activeTitleScreen > -1) titleScreens[activeTitleScreen].script.executeFunc("beatHit");
			if ((curBeat - skipBeat) % 24 == 0) {
				switchTitleScreen();
			}
		}
		// if (logoBl != null) logoBl.animation.play('bump');
		// danceLeft = !danceLeft;
		// if (gfDance != null) {
		// 	if (danceLeft)
		// 		gfDance.animation.play('danceRight');
		// 	else
		// 		gfDance.animation.play('danceLeft');
		// }

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['In association', 'with']);
			case 7:
				addMoreText('newgrounds');
				ngSpr.visible = true;
			// credTextShit.text += '\nNewgrounds';
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 11:
				addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('Friday Night Funkin\'');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Yoshi');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText('Engine'); // credTextShit.text += '\nFunkin';

			case 16:
				skipBeat = 16;
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
		switchTitleScreen();
	}
}
