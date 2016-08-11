package;

import RcLib;

import haxe.CallStack;

import State.DirUtil;
import State.Coord;
import State.StaredustState;
import State.TileEnum;
import State.SpriteTypeEnum;
import State.SpriteInfo;

private typedef TileDataRec = {
    _tile:TileEnum,
    _move:String,
    _magic:String
}

//trace(CallStack.toString(CallStack.callStack()));

class StaredustLogic
{
    public static var TileRules:Array<TileDataRec> = [
	{_tile: Empty, _move: 'udrl', _magic: 'udrl'},
	{_tile: Estar, _move: '', _magic: 'udrl'},
	{_tile: Istar, _move: '', _magic: ''},
	{_tile: Start, _move: 'udrl', _magic: ''},
	{_tile: Exit, _move: 'udrl', _magic: ''},
	{_tile: Warp, _move: 'd', _magic: 'rl'},
	{_tile: Purple, _move: '', _magic: ''},
	{_tile: Star, _move: 'udrl', _magic: 'u'},
	{_tile: Fall, _move: '', _magic: ''},
	{_tile: Left, _move: 'l', _magic: ''},
	{_tile: Right, _move: 'r', _magic: ''},
	{_tile: Elevator, _move: 'udrl', _magic: ''},
	{_tile: Tunnel, _move: 'rl', _magic: ''},
	{_tile: Blue, _move: '', _magic: 'udrl'},
	{_tile: Green, _move: '', _magic: 'udrl'},
    ];

    var _state:StaredustState;
    
    public function new(state:StaredustState) {
	_state = state;
    }

    private function isOutOfBounds(pos:Coord):Bool {
	return pos._y < 0 || pos._y >= _state._height || pos._x < 0 || pos._x >= _state._width;
    }

    function writeGrid(pos:Coord, value:TileEnum):Void {
	if (!isOutOfBounds(pos)) {
	    var i = pos._x+_state._width*pos._y;
	    _state._world[i] = value;
	}
    }

    function readGrid(pos:Coord):TileEnum {
	if (isOutOfBounds(pos)) {
	    return OutOfBounds;
	} else {
	    var i = pos._x+_state._width*pos._y;
	    return _state._world[i];
	}
    }

    function triggerTileAnim(pos:Coord):Void {
	var info:SpriteInfo = Dummy;
	switch (readGrid(pos)) {
	case Estar:
	    info = Directionless(EstarVanish);
	case Warp:
	    info = Directionless(WarpVanish);
	case Blue:
	    info = Directionless(BlueVanish);
	case Green:
	    info = Directionless(GreenVanish);
	case Fall:
	    info = Directionless(FallBreak);
	case Empty:
	    info = Directional(BlueMagic, DirUtil.lrMask(_state._playerdir));
	default:
	    trace("something bad happened!");
	};
	_state._anims.push({_pos: pos, _info: info, _isplayer: false, _isover: false});
    }

    function triggerPlayerAnim(type:SpriteTypeEnum, ?pos:Coord):Void {
	if (pos == null) {
	    pos = _state._player;
	}

	var info:SpriteInfo = Dummy;
	switch (type) {
	case PlayerWalk | PlayerVanish | PlayerBump | PlayerKneel | PlayerClick:
	    info = Directional(type, DirUtil.lrMask(_state._playerdir));
	case PlayerMagic:
	    if (DirUtil.dirContains(_state._playerdir, DirUtil.UP)) {
		pos = pos.stepInDir(DirUtil.UP);
	    }
	    info = Directional(type, _state._playerdir);
	case PlayerSpawn:
	    pos = _state._start;
	    info = Directional(PlayerSpawn, DirUtil.lrMask(_state._playerdir));
	case PlayerFall:
	    _state._playerisfalling = true;
	    info = Directional(PlayerFall, DirUtil.lrMask(_state._playerdir));
	default:
	    trace("something bad happened", Std.string(type));
	}
	
	_state._anims.push({_pos: pos, _info: info, _isplayer: true, _isover: false});
	_state._playerlocked = true;
    }

    function tryMagic(pos:Coord):Void {
	RcLib.assert(false);
    }

    function isCoordAnimating(pos:Coord):Bool {
	for (rec in _state._anims) {
	    if (pos.equals(rec._pos) && !rec._isplayer) {
		return true;
	    }
	}
	
	return false;
    }

    function canTileMagic(tile:TileEnum, dir:String):Bool {
	for (rec in TileRules) {
	    if (rec._tile == tile) {
		return DirUtil.dirContains(rec._magic, dir);
	    }
	}
	trace("something bad happened!");
	return false;
    }
    
    function canTileMove(tile:TileEnum, dir:String):Bool {
	for (rec in TileRules) {
	    if (rec._tile == tile) {
		return DirUtil.dirContains(rec._move, dir);
	    }
	}
	trace("something bad happened!");
	return false;
    }

    public function update():Void {
	if (_state._editmode) {
	    _state._playerdead = true;
	    _state._anims = new Array();
	    return;
	}
	
	// 1. PROCESS TILE ANIMATIONS
	_state._anims = _state._anims.filter(function (anim) {
	    if (!anim._isplayer && anim._isover) {
		switch (anim._info) {
		case Directionless(FallBreak | EstarVanish | BlueVanish | GreenVanish | WarpVanish):
		    trace("clearing it");
		    writeGrid(anim._pos, Empty);
		case Directional(BlueMagic, dir):
		    writeGrid(anim._pos, Blue);
		    if (readGrid(anim._pos.below()) == Purple) {
			triggerTileAnim(anim._pos);
		    }
		default:
		}
		return false;
	    }
	    return true;
	});


	// 2. PROCESS PLAYER ANIMATION
	for (anim in _state._anims) {
	    if (anim._isplayer && anim._isover) {
		switch (anim._info) {
		case Directional(PlayerFall, dir):
		    _state._playerisfalling = false;
		    _state._player = _state._player.below();
		    if (_state._player._y >= _state._height) {
			_state._playerdead = true;
		    }
		case Directional(PlayerSpawn, dir):
		    _state._player = _state._start;
		    _state._playerdir = DirUtil.RIGHT;
		case Directional(PlayerVanish, dir):
		    _state._playerdead = true;
		case Directional(PlayerWalk, dir):
		    _state._player = _state._player.stepInDir(dir);
		case Directional(PlayerKneel, dir):
		    _state._playerdir = DirUtil.normalize(dir, DirUtil.DOWN);
		case Directional(PlayerMagic, DirUtil.UPRIGHT | DirUtil.UPLEFT):
		    writeGrid(_state._player, Green);
		    _state._player = _state._player.stepInDir(DirUtil.UP);
		case Directionless(Spiral):
		    trace("congrats you win: TODO");
		default:
		}

		_state._playerlocked = false;
		_state._anims.remove(anim);
		break;
	    }
	}

	// 3. SEARCH FOR AND FIND EVENTS TO DEAL WITH
	{
	    // TODO: assimilate the l/r crap
	    var playerleftright = DirUtil.lrMask(_state._playerdir);
	    var playerupdown = DirUtil.udMask(_state._playerdir);

	    var inputupdown = DirUtil.udMask(_state._inputdir);
	    var inputleftright = DirUtil.lrMask(_state._inputdir);
	    var inputmagic = _state._inputmagic;
	    var inputavailable = DirUtil.NONE != _state._inputdir || inputmagic;

	    var playertile = readGrid(_state._player);

	    var fallcoord = _state._player.below();
	    var falltile = readGrid(fallcoord);
	    var canfall = (!_state._playerdead && _state._player._y == _state._height - 1) || (falltile != OutOfBounds && canTileMove(falltile, DirUtil.DOWN));

	    var movecoord = _state._player.stepInDir(playerleftright);
	    var movetile = readGrid(movecoord);
	    var canmove = movetile != OutOfBounds && canTileMove(movetile, playerleftright);

	    var greencoord = _state._player.stepInDir(DirUtil.UP);
	    var greentile = readGrid(greencoord);
	    var cangreen = greentile != OutOfBounds && canTileMove(greentile, DirUtil.UP) && canTileMagic(greentile, DirUtil.UP);
	    var canvanishgreen = greentile != OutOfBounds && greentile == Green;

	    var magicdir = playerupdown == DirUtil.UP ? DirUtil.NONE : _state._playerdir;
	    var magiccoord = _state._player.stepInDir(magicdir);
	    var magictile = readGrid(magiccoord);
	    var canmagic = magictile != OutOfBounds && canTileMagic(magictile, _state._playerdir);

	    var isfalling = _state._playerisfalling;

	    // TRIGGERED TILE EVENTS
	    if (!_state._playerlocked && falltile != OutOfBounds && !isCoordAnimating(fallcoord)) {
		switch (falltile) {
		case Fall:
		    triggerTileAnim(fallcoord);
		default:
		}
	    }

	    // PLAYER ACTION EVENTS
	    if (isfalling && inputavailable) {
		// special weird case to swizzle in mid-air
		if (inputleftright == DirUtil.opposite(playerleftright)) {
		    _state._playerdir = DirUtil.normalize(playerupdown, inputleftright);
		}
	    } else if (_state._playerlocked) {
		// if the player is locked, there's nothing else to do other than keep animating
	    } else if (_state._playerdead) {
		triggerPlayerAnim(PlayerSpawn, _state._start);
		_state._playerdead = false;
	    } else if (playertile == Warp || falltile == Purple) {
		triggerPlayerAnim(PlayerVanish);
	    } else if (canfall) {
		triggerPlayerAnim(PlayerFall);
	    } else {
		// actions based on player input
		if (inputleftright == DirUtil.opposite(playerleftright) || playerupdown != inputupdown) {
		    // "minor" acitons
		    if (inputleftright == DirUtil.opposite(playerleftright)) {
			playerleftright = inputleftright;
		    }
		    
		    if (playerupdown == DirUtil.NONE && inputupdown == DirUtil.DOWN) {
			triggerPlayerAnim(PlayerKneel);
		    } else {
			// trigger exit
			if (inputupdown == DirUtil.UP && playertile == Exit) {
			    RcLib.assert(false);
			}
			_state._playerdir = DirUtil.normalize(inputupdown, playerleftright);
		    }
		} else if (inputleftright != DirUtil.NONE && canmove) {
		    triggerPlayerAnim(PlayerWalk);
		} else if (inputleftright != DirUtil.NONE) {
		    triggerPlayerAnim(PlayerBump);
		} else if (inputmagic && playerupdown == DirUtil.DOWN && falltile == Green) {
		    // 1. if magic is applied while looking down and standing on green, destroy green
		    triggerPlayerAnim(PlayerClick);
		    triggerTileAnim(fallcoord);
		} else if (inputmagic && inputupdown == DirUtil.UP && falltile != Green && cangreen && canmagic) {
		    // 2. boost magic if not on green and canmagic on player tile
		    triggerPlayerAnim(PlayerMagic);
		} else if (inputmagic && inputupdown == DirUtil.UP && canvanishgreen) {
		    // 3. if looking up and green above, destroy the green
		    triggerPlayerAnim(PlayerClick);
		    triggerTileAnim(greencoord);
		} else if (inputmagic && inputupdown == DirUtil.UP) {
		    // 4. if looking up and couldn't vanish a green or boost, just click
		    triggerPlayerAnim(PlayerClick);
		} else if (inputmagic) {
		    // blue magic
		    triggerPlayerAnim(PlayerMagic);
		    if (canmagic) {
			triggerTileAnim(magiccoord);
		    }
		}
	    }
	}
    }

    public function loadLevel():Void {

    }
}
