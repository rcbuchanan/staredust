package;

import flash.geom.Point;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.util.FlxStringUtil;

import State.Anim;
import State.TileEnum;
import State.SpriteInfo;
import State.Coord;
import State.DirUtil;
import State.StaredustState;

private typedef SpriteMetadata = {
    var _info:SpriteInfo;
    var _frames:Array<Int>;
}

private typedef AnimSpritePair = {
    var _anim:Anim;
    var _sprite:FlxSprite;
    var _ultimateFrame:Bool;
}

class StaredustFlixelView {
    static inline var TileSize = 40;
    static inline var TSW = 6;
    static inline var PSW = 12;
    static inline var BSW = 5;
    static inline var TileSpritePoolSize = 8;
    static inline var TSS = "images/tile.png";
    static inline var BSS = "images/boost.png";
    static inline var PSS = "images/player.png";

    private static var TileSpriteMetadata:Array<SpriteMetadata> = [
	{_info: Tile(Empty), _frames: [0+TSW*0]},
	{_info: Tile(Estar), _frames: [0+TSW*1, 0+TSW*2, 0+TSW*3, 0+TSW*4, 0+TSW*5, 0+TSW*6, 0+TSW*7, 0+TSW*8, 0+TSW*9]},
	{_info: Tile(Istar), _frames: [1+TSW*1, 1+TSW*2, 1+TSW*3, 1+TSW*4, 1+TSW*5, 1+TSW*6, 1+TSW*7, 1+TSW*8, 1+TSW*9]},
	{_info: Tile(Fall), _frames: [4+TSW*6]},
	{_info: Tile(Star), _frames: [4+TSW*5]},
	{_info: Tile(Start), _frames: [3+TSW*9]},
	{_info: Tile(Exit), _frames: [3+TSW*10]},
	{_info: Tile(Warp), _frames: [4+TSW*3]},
	{_info: Tile(Blue), _frames: [0+TSW*10]},
	{_info: Tile(Green), _frames: [3+TSW*3]},
	{_info: Tile(Purple), _frames: [4+TSW*4]},

	{_info: Directional(BlueMagic, DirUtil.LEFT), _frames: [0+TSW*0, 1+TSW*0, 2+TSW*0]},
	{_info: Directional(BlueMagic, DirUtil.RIGHT), _frames: [2+TSW*10, 1+TSW*10, 0+TSW*10]},
	{_info: Directionless(BlueVanish), _frames: [2+TSW*6, 2+TSW*7, 2+TSW*8, 2+TSW*9, 2+TSW*10]},
	{_info: Directionless(EstarVanish), _frames: [2+TSW*1, 2+TSW*2, 2+TSW*3, 2+TSW*4, 2+TSW*5]},
	{_info: Directionless(GreenVanish), _frames: [3+TSW*3, 3+TSW*4, 3+TSW*5, 3+TSW*6, 3+TSW*7, 3+TSW*8]},
	{_info: Directionless(WarpVanish), _frames: [4+TSW*10]},
	{_info: Directionless(FallBreak), _frames: [4+TSW*7, 4+TSW*8, 4+TSW*9]},
    ];

    private static var BoostSpriteMetadata:Array<SpriteMetadata> = [
	{_info: Directional(PlayerMagic, DirUtil.UPRIGHT), _frames: [0+BSW*0, 1+BSW*0, 2+BSW*0, 3+BSW*0, 4+BSW*0]},
	{_info: Directional(PlayerMagic, DirUtil.UPLEFT), _frames: [0+BSW*1, 1+BSW*1, 2+BSW*1, 3+BSW*1, 4+BSW*1]},
    ];
    
    private static var PlayerSpriteMetadata:Array<SpriteMetadata> = [
	{_info: Directional(PlayerStand, DirUtil.RIGHT), _frames: [0+PSW*0]},
	{_info: Directional(PlayerStand, DirUtil.DOWNRIGHT), _frames: [2+PSW*7]},
	{_info: Directional(PlayerStand, DirUtil.UPRIGHT), _frames: [4+PSW*7]},
	{_info: Directional(PlayerStand, DirUtil.LEFT), _frames: [11+PSW*0]},
	{_info: Directional(PlayerStand, DirUtil.DOWNLEFT), _frames: [9+PSW*7]},
	{_info: Directional(PlayerStand, DirUtil.UPLEFT), _frames: [7+PSW*7]},
	
	{_info: Directional(PlayerBump, DirUtil.RIGHT), _frames: [0+PSW*1, 0+PSW*2, 0+PSW*3, 0+PSW*2, 0+PSW*1]},
	{_info: Directional(PlayerKneel, DirUtil.RIGHT), _frames: [2+PSW*6]},
	{_info: Directional(PlayerClick, DirUtil.DOWNRIGHT), _frames: [2+PSW*8, 2+PSW*8, 2+PSW*8, 2+PSW*8, 2+PSW*8, 2+PSW*8]},
	{_info: Directional(PlayerWalk, DirUtil.RIGHT), _frames: [0+PSW*1, 0+PSW*2, 0+PSW*3, 0+PSW*4, 0+PSW*5, 0+PSW*6, 0+PSW*7, 0+PSW*8]},
	{_info: Directional(PlayerVanish, DirUtil.RIGHT), _frames: [5+PSW*0, 5+PSW*1, 5+PSW*2, 5+PSW*3, 5+PSW*4, 5+PSW*5, 5+PSW*6, 5+PSW*7]},
	{_info: Directional(PlayerSpawn, DirUtil.RIGHT), _frames: [5+PSW*7, 5+PSW*6, 5+PSW*5, 5+PSW*4, 5+PSW*3, 5+PSW*2, 5+PSW*1, 5+PSW*0]},
	{_info: Directional(PlayerFall, DirUtil.RIGHT), _frames: [3+PSW*0, 3+PSW*1, 3+PSW*2, 3+PSW*3]},
	{_info: Directional(PlayerMagic, DirUtil.RIGHT), _frames: [2+PSW*0, 2+PSW*1, 2+PSW*2, 2+PSW*3, 2+PSW*2, 2+PSW*1, 2+PSW*0]},
	{_info: Directional(PlayerMagic, DirUtil.DOWNRIGHT), _frames: [4+PSW*0, 4+PSW*1, 4+PSW*2, 4+PSW*3, 4+PSW*2, 4+PSW*1, 4+PSW*0]},
	{_info: Directional(PlayerClick, DirUtil.UPRIGHT), _frames: [4+PSW*4, 4+PSW*5, 4+PSW*6, 4+PSW*5]},
	{_info: Directional(PlayerClick, DirUtil.UPLEFT), _frames: [7+PSW*4, 7+PSW*5, 7+PSW*6, 7+PSW*5]},
	{_info: Directional(PlayerBump, DirUtil.LEFT), _frames: [11+PSW*1, 11+PSW*2, 11+PSW*3, 11+PSW*2, 11+PSW*1]},
	{_info: Directional(PlayerKneel, DirUtil.LEFT), _frames: [9+PSW*6]},
	{_info: Directional(PlayerClick, DirUtil.DOWNLEFT), _frames: [9+PSW*8, 9+PSW*8, 9+PSW*8, 9+PSW*8, 9+PSW*8, 9+PSW*8]},
	{_info: Directional(PlayerWalk, DirUtil.LEFT), _frames: [11+PSW*1, 11+PSW*2, 11+PSW*3, 11+PSW*4, 11+PSW*5, 11+PSW*6, 11+PSW*7, 11+PSW*8]},
	{_info: Directional(PlayerVanish, DirUtil.LEFT), _frames: [6+PSW*0, 6+PSW*1, 6+PSW*2, 6+PSW*3, 6+PSW*4, 6+PSW*5, 6+PSW*6, 6+PSW*7]},
	{_info: Directional(PlayerSpawn, DirUtil.LEFT), _frames: [6+PSW*7, 6+PSW*6, 6+PSW*5, 6+PSW*4, 6+PSW*3, 6+PSW*2, 6+PSW*1, 6+PSW*0]},
	{_info: Directional(PlayerFall, DirUtil.LEFT), _frames: [8+PSW*0, 8+PSW*1, 8+PSW*2, 8+PSW*3]},
	{_info: Directional(PlayerMagic, DirUtil.LEFT), _frames: [9+PSW*0, 9+PSW*1, 9+PSW*2, 9+PSW*3, 9+PSW*2, 9+PSW*1, 9+PSW*0]},
	{_info: Directional(PlayerMagic, DirUtil.DOWNLEFT), _frames: [7+PSW*0, 7+PSW*1, 7+PSW*2, 7+PSW*3, 7+PSW*2, 7+PSW*1, 7+PSW*0]}
    ];
    
    var _state:StaredustState;
    var _tilemap:FlxTilemap;
    var _flixel:FlxState;
    
    var _playerSprite:FlxSprite;
    var _tileSpritePool:Array<FlxSprite> = new Array();
    var _boostSprite:FlxSprite;
    
    var _animatingSprites:Array<AnimSpritePair> = new Array();
    
    var _editModeTileIndex:Int = 0;
    var _editModeTileSprite:FlxSprite;

    var _mouseX:Int;
    var _mouseY:Int;

    public function new(state:StaredustState, flixelState:FlxState) {
	_state = state;
	_flixel = flixelState;
    }

    private function getMapIndexForTile(tileType:TileEnum, pos:Int = 0):Int {
	for (spriterec in TileSpriteMetadata) {
	    switch (spriterec._info) {
	    case Tile(x):
		if (x == tileType) {
		    var id = Std.int((pos * 2654435761) % spriterec._frames.length);
		    return spriterec._frames[id];
		}
	    default:
	    }
	}
	return -1;
    }

    public function init() {

	// create tilemap for world
	{
	    var worldSpriteIndicies:Array<Int> = new Array();

	    for (i in 0 ... _state._world.length) {
		var mapi = getMapIndexForTile(_state._world[i], i);

		if (mapi >= 0) {
		    worldSpriteIndicies.push(mapi);
		} else {
		    trace("Unindentified tile!!");
		}
	    }

	    _tilemap = new FlxTilemap();
	    _tilemap.loadMap(FlxStringUtil.arrayToCSV(worldSpriteIndicies, _state._width), TSS, TileSize, TileSize, FlxTilemap.OFF, 0, 0);
	    _flixel.add(_tilemap);
	}

	// create edit mode overlay sprite
	{
	    _editModeTileSprite = new FlxSprite();
	    _editModeTileSprite.makeGraphic(TileSize, TileSize);
	    var i = getMapIndexForTile(_state._editmodetile);
	    _editModeTileSprite.pixels.copyPixels(_tilemap.cachedGraphics.bitmap, _tilemap.framesData.frames[i].frame, new Point(0, 0));
	    
	    _editModeTileSprite.x = 0;
	    _editModeTileSprite.y = 0;
	    _editModeTileSprite.visible = false;
	    _flixel.add(_editModeTileSprite);
	}

	// create player sprite w/ animations
	{
	    _playerSprite = new FlxSprite(TileSize, TileSize);
	    _playerSprite.visible = false;

	    _playerSprite.loadGraphic(PSS, true, TileSize, TileSize);

	    for (rec in PlayerSpriteMetadata) {
		_playerSprite.animation.add(Std.string(rec._info), rec._frames, PlayState.FPS, false);
	    }

	    _flixel.add(_playerSprite);
	}

	// create tile sprite pool animations
	for (i in 0 ... TileSpritePoolSize) {
	    var sprite = new FlxSprite(TileSize, TileSize);
	    sprite.visible = false;
	    
	    sprite.loadGraphic(TSS, true, TileSize, TileSize);

	    for (rec in TileSpriteMetadata) {
		sprite.animation.add(Std.string(rec._info), rec._frames, PlayState.FPS, false);
	    }

	    _tileSpritePool.push(sprite);
	    _flixel.add(sprite);
	}

	// create player boost sprite
	{
	    _boostSprite = new FlxSprite(TileSize, TileSize * 2);
	    _boostSprite.visible = false;

	    _boostSprite.loadGraphic(BSS, true, TileSize, TileSize * 2);

	    for (rec in BoostSpriteMetadata) {
		_boostSprite.animation.add(Std.string(rec._info), rec._frames, PlayState.FPS, false);
	    }

	    _flixel.add(_boostSprite);
	}
    }

    public function repaint() {
	// make sure tile map is up to date
	for (i in 0 ... _state._world.length) {
	    var ti = getMapIndexForTile(_state._world[i], i);
	    _tilemap.setTileByIndex(i, ti);
	}

	// wrap-up animations that have ended
	_animatingSprites = _animatingSprites.filter(function (rec:AnimSpritePair):Bool {
	    if (rec._ultimateFrame) {
		rec._sprite.visible = false;
		return false;
	    } else if (rec._sprite.animation.finished) {
		rec._anim._isover = true;
		rec._ultimateFrame = true;
	    }

	    return true;
	});

	// update animations
	for (anim in _state._anims) {
	    if (anim._isover) {
		continue;
	    }

	    // find sprite
	    var animSprite:Null<FlxSprite> = null;
	    for (rec in _animatingSprites) {
		if (rec._anim == anim) {
		    animSprite = rec._sprite;
		    break;
		}
	    }

	    // attach sprites to new anims
	    if (animSprite == null) {
		switch (anim._info) {
		case Tile(tileType):
		    // pull out of anim pool
		case Directional(PlayerMagic, DirUtil.UPLEFT | DirUtil.UPRIGHT):
		    _playerSprite.visible = false;
		    animSprite = _boostSprite;
		case Directional(BlueMagic, _)  | Directionless(BlueVanish | EstarVanish | GreenVanish | WarpVanish | FallBreak):
		    for (sprite in _tileSpritePool) {
			if (sprite.animation.curAnim == null) {
			    trace("hit");
			    animSprite = sprite;
			    break;
			}
		    }
		    if (animSprite == null) {
			trace("something bad happened! tileSpritePool is empty!");
		    }
		case Directional(x, dir):
		    if (x == PlayerSpawn) {
			_playerSprite.visible = true;
		    }
		    animSprite = _playerSprite;
		default:
		    trace("something bad happened!", anim._info);
		}

		_animatingSprites.push({_anim: anim, _sprite: animSprite, _ultimateFrame: false});
		animSprite.setPosition(anim._pos._x * TileSize, anim._pos._y * TileSize);
		animSprite.visible = true;
		animSprite.animation.play(Std.string(anim._info));
	    }

	    // apply lerp for certain player animations
	    {
		var pos2:Null<Coord> = null;
		switch (anim._info) {
		case Directional(PlayerFall, dir): pos2 = anim._pos.below();
		case Directional(PlayerWalk, dir): pos2 = anim._pos.stepInDir(DirUtil.lrMask(_state._playerdir));
		default:
		}
		if (pos2 != null) {
		    var r:Float = (animSprite.animation.curAnim.curFrame + 1) / animSprite.animation.curAnim.numFrames;
		    animSprite.x = TileSize * (anim._pos._x + r * (pos2._x - anim._pos._x));
		    animSprite.y = TileSize * (anim._pos._y + r * (pos2._y - anim._pos._y));
		}
	    }
	}

	// update the ever-present player sprite if not animating
	if (!_state._playerlocked) {
	    _playerSprite.animation.play(Std.string(Directional(PlayerStand, _state._playerdir)));
	    _playerSprite.setPosition(TileSize * _state._player._x, TileSize * _state._player._y);
	    _playerSprite.visible = !_state._playerdead;
	}


	if (_state._editmode) {
	    var i:Int = getMapIndexForTile(_state._editmodetile);
	    _editModeTileSprite.pixels.copyPixels(_tilemap.cachedGraphics.bitmap, _tilemap.framesData.frames[i].frame, new Point(0, 0));

	    _editModeTileSprite.visible = true;
	    _editModeTileSprite.x = _mouseX;
	    _editModeTileSprite.y = _mouseY;
	} else {
	    _editModeTileSprite.visible = false;
	}
    }

    public function updateInput() {
	var dir = "";
	if (FlxG.keys.pressed.LEFT) {
	    dir += DirUtil.LEFT;
	}
	if (FlxG.keys.pressed.RIGHT) {
	    dir += DirUtil.RIGHT;
	}
	if (FlxG.keys.pressed.UP) {
	    dir += DirUtil.UP;
	}
	if (FlxG.keys.pressed.DOWN) {
	    dir += DirUtil.DOWN;
	}

	_state._inputmagic = FlxG.keys.pressed.SPACE;
	_state._inputdir = DirUtil.normalize(dir);

	// for edit mode
	if (FlxG.keys.justPressed.TAB) {
	    _state._editmode =  !_state._editmode;
	}
	if (FlxG.keys.justPressed.S) {
	    _state._editmodemsgs.push(WriteLevel);
	}
	if (FlxG.keys.justPressed.N) {
	    _state._editmodemsgs.push(NextLevel);
	}
	if (FlxG.keys.justPressed.P) {
	    _state._editmodemsgs.push(PrevLevel);
	}
	
	_mouseX = FlxG.mouse.screenX;
	_mouseY = FlxG.mouse.screenY;
	
	_state._editmodetilepos = Std.int(_mouseX / TileSize) + Std.int(_mouseY / TileSize) * _state._width;

	if (FlxG.mouse.justPressed) {
	    _state._editmodemsgs.push(PutTile);
	}
	
	if (FlxG.mouse.justPressedRight) {
	    _state._editmodemsgs.push(CopyTile);
	}

	if (FlxG.mouse.wheel > 0) {
	    _state._editmodemsgs.push(NextTile);
	} else if (FlxG.mouse.wheel < 0) {
	    _state._editmodemsgs.push(PrevTile);
	}
    }
}
