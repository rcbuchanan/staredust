package;

import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxColor;

import State.StaredustState;
import Loader.StaredustLoader;
import Logic.StaredustLogic;
import FlixelView.StaredustFlixelView;

/**
 * Flixel graphics + glue
 */

class PlayState extends FlxState {
    public static inline var FPS = 30;
    var _state:StaredustState;
    var _logic:StaredustLogic;
    var _loader:StaredustLoader;
    var _flixelview:StaredustFlixelView;
    
    override public function create():Void {
	//FlxG.mouse.visible = false;
	FlxG.cameras.bgColor = 0xffaaaaaa;
	
	_state = new StaredustState();
	_logic = new StaredustLogic(_state);
	_loader = new StaredustLoader(_state);
	_flixelview = new StaredustFlixelView(_state, this);

	_loader.loadLevelSet("levels/levelset.txt", true);
	//_loader.loadLevelSet("C:/Users/rc/Documents/staredust/level_workspace/levelset.txt", false);
	_loader.loadLevel(1);
	_flixelview.init();

	super.create();
    }
    
    override public function destroy():Void {
	super.destroy();
    }
    
    override public function update():Void {
	super.update();

	_flixelview.updateInput();
	_logic.update();
	_loader.update();
	_flixelview.repaint();

    }
}
