package;

import flash.geom.Point;

import RcLib;

enum TileEnum {
    OutOfBounds;
    Empty;
    Estar;
    Istar;
    Start;
    Exit;
    Warp;
    Purple;
    Star;
    Fall;
    Left;
    Right;
    Elevator;
    Tunnel;
    Blue;
    Green;
}

enum SpriteTypeEnum {
    BlueMagic;
    BlueVanish;
    EstarVanish;
    GreenVanish;
    WarpVanish;
    FallBreak;

    PlayerStand;
    PlayerBump;
    PlayerKneel;
    PlayerClick;
    PlayerWalk;
    PlayerVanish;
    PlayerSpawn;
    PlayerFall;
    PlayerMagic;

    Spiral;
}

enum SpriteInfo {
    Tile(tile:TileEnum);
    Directionless(type:SpriteTypeEnum);
    Directional(type:SpriteTypeEnum, dir:String);
    Dummy;
}

enum EditModeMsg {
    NextTile;
    PrevTile;
    PutTile;
    CopyTile;
    WriteLevel;
    NextLevel;
    PrevLevel;
}

typedef Anim = {
    var _pos:Coord;
    var _info:SpriteInfo;
    var _isplayer:Bool;
    var _isover:Bool;
}

class DirUtil {
    public static inline var UP = 'u';
    public static inline var DOWN = 'd';
    public static inline var LEFT = 'l';
    public static inline var RIGHT = 'r';
    public static inline var UPLEFT = 'ul';
    public static inline var UPRIGHT = 'ur';
    public static inline var DOWNLEFT = 'dl';
    public static inline var DOWNRIGHT = 'dr';
    public static inline var NONE = '';
    
    public static function normalize(dir1:String, ?dir2:String):String {
	var l1 = dir1.indexOf('l') >= 0;
	var r1 = dir1.indexOf('r') >= 0;
	var u1 = dir1.indexOf('u') >= 0;
	var d1 = dir1.indexOf('d') >= 0;

	var l0 = l1 && !r1;
	var r0 = r1 && !l1;
	var u0 = u1 && !d1;
	var d0 = d1 && !u1;

	if (dir2 != null) {
	    var l2 = dir2.indexOf('l') >= 0;
	    var r2 = dir2.indexOf('r') >= 0;
	    var u2 = dir2.indexOf('u') >= 0;
	    var d2 = dir2.indexOf('d') >= 0;
	    
	    if (l2 && !r2) {
		l0 = true;
		r0 = false;
	    }

	    if (r2 && !l2) {
		l0 = false;
		r0 = true;
	    }

	    if (u2 && !d2) {
		u0 = true;
		d0 = false;
	    }

	    if (d2 && !u2) {
		u0 = false;
		d0 = true;
	    }
	}

	return (u0 ? "u" : "") + (d0 ? "d" : "") + (l0 ? "l" : "") + (r0 ? "r" : "");
    }

    public static function dirContains(dir:String, dirinside:String):Bool {
	var l1 = dir.indexOf('l') >= 0;
	var r1 = dir.indexOf('r') >= 0;
	var u1 = dir.indexOf('u') >= 0;
	var d1 = dir.indexOf('d') >= 0;

	var l2 = dirinside.indexOf('l') >= 0;
	var r2 = dirinside.indexOf('r') >= 0;
	var u2 = dirinside.indexOf('u') >= 0;
	var d2 = dirinside.indexOf('d') >= 0;

	var lf = l2 && !l1;
	var rf = r2 && !r1;
	var uf = u2 && !u1;
	var df = d2 && !d1;

	return !(lf || rf || uf || df);
    }

    public static function udMask(dir:String):String {
	return (dir.indexOf("u") >= 0 ? "u" : "") + (dir.indexOf("d") >= 0 ? "d" : "");
    }

    public static function lrMask(dir:String):String {
	return (dir.indexOf("l") >= 0 ? "l" : "") + (dir.indexOf("r") >= 0 ? "r" : "");
    }

    public static function opposite(dir:String):String {
	var l1 = dir.indexOf('l') >= 0;
	var r1 = dir.indexOf('r') >= 0;
	var u1 = dir.indexOf('u') >= 0;
	var d1 = dir.indexOf('d') >= 0;

	var l0 = !l1 && r1;
	var r0 = !r1 && l1;
	var u0 = !u1 && d1;
	var d0 = !d1 && u1;

	return (u0 ? "u" : "") + (d0 ? "d" : "") + (l0 ? "l" : "") + (r0 ? "r" : "");
    }
}

class Coord
{
    public var _x(default, null):Int;
    public var _y(default, null):Int;

    public function new(x:Int, y:Int) {
	_x = x;
	_y = y;
    }

    public function below():Coord {
	return new Coord(_x, _y + 1);
    }

    public function stepInDir(dir:String):Coord {
	var newx = _x;
	var newy = _y;
	dir = DirUtil.normalize(dir);

	if (DirUtil.dirContains(dir, DirUtil.UP)) {
	    newy--;
	} else if (DirUtil.dirContains(dir, DirUtil.DOWN)) {
	    newy++;
	}

	if (DirUtil.dirContains(dir, DirUtil.LEFT)) {
	    newx--;
	} else if (DirUtil.dirContains(dir, DirUtil.RIGHT)) {
	    newx++;
	}

	return new Coord(newx, newy);
    }

    public function equals(rhs:Coord):Bool {
	return (_x == rhs._x && _y == rhs._y);
    }

}

class StaredustState {
    public var _width:Int = 0;
    public var _height:Int = 0;

    public var _levelpaths:Array<String>;
    public var _loadlevelsfromassets:Bool;
    public var _activelevelnum:Int;

    public var _world:Array<TileEnum> = new Array();
    public var _start:Coord = new Coord(0, 0);

    public var _player:Coord = new Coord(0, 0);
    public var _playerdir:String = DirUtil.RIGHT;
    
    public var _playerdead:Bool = true;
    public var _playerlocked:Bool = false;
    public var _playerisfalling:Bool = false;

    public var _anims:Array<Anim> = new Array();

    public var _editmode:Bool = true;
    public var _editmodetile:TileEnum = Empty;
    public var _editmodetilepos:Int = 0;
    public var _editmodemsgs:List<EditModeMsg> = new List();
    
    public var _inputdir:String = DirUtil.NONE;
    public var _inputmagic:Bool = false;

    public function new() {
    }
}
