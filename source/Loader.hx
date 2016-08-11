package;

import haxe.io.Path;

import openfl.Assets;

//import sys.io.File;

import State.Coord;
import State.DirUtil;
import State.StaredustState;
import State.TileEnum;


private typedef TileDataRec = {
    tile:TileEnum,
    sym:String,
}

class StaredustLoader {
    private static var Tilesyms:Array<TileDataRec> = [
	{tile: Empty, sym: '0'},
	{tile: Estar, sym: '1'},
	{tile: Istar, sym: '2'},
	{tile: Start, sym: '3'},
	{tile: Exit, sym: '4'},
	{tile: Warp, sym: '5'},
	{tile: Purple, sym: '6'},
	{tile: Star, sym: '7'},
	{tile: Fall, sym: '8'},
	{tile: Left, sym: '!'},
	{tile: Right, sym: '@'},
	{tile: Elevator, sym: '#'},
	{tile: Tunnel, sym: '$'},
    ];

    private static var EditTileCycle:Array<TileEnum> = [
	Green, Estar, Istar, Start, Exit, Warp, Purple, Star, Fall,
    ];
    var _editTileCyclePos:Int = 0;

    var _state:StaredustState;
    
    public function new(state:StaredustState) {
	_state = state;
    }

    public function loadLevelSet(path:String, loadFromAssets:Bool):Void {
	_state._levelpaths = new Array();
	_state._loadlevelsfromassets = loadFromAssets;
	
	var txt:String;
	txt = Assets.getText(path);


	var basepath = Path.directory(path);
	for (levelpath in new EReg("[\n\r]+", "g").split(txt)) {
	    _state._levelpaths.push(Path.join([basepath, levelpath]));
	}
    }

    public function loadLevel(levelnum:Int):Void {
	var path:String = _state._levelpaths[levelnum - 1];
	var txt:String;

	trace(path);
	
	txt = Assets.getText(path);

	var newWorld = new Array();
	var newWidth:Int = -1;

	for (sym in txt.split("")) {
	    if (sym == "\n" || sym == "\r") {
		if (newWidth == -1) {
		    newWidth = newWorld.length;
		}
		
		continue;
	    }
	    
	    var found = false;
	    for (tilesym in Tilesyms) {
		if (tilesym.sym == sym) {
		    newWorld.push(tilesym.tile);

		    found = true;
		    break;
		}
	    }

	    if (!found) {
		trace("unidentified symbol '" + sym + "' found in file @ " + path);
	    }
	}

	var newStart = new Coord(newWorld.indexOf(Start) % newWidth, Std.int(newWorld.indexOf(Start) / newWidth));
	var newHeight:Int = Std.int(newWorld.length / newWidth);

	_state._activelevelnum = levelnum;

	_state._width = newWidth;
	_state._height = newHeight;
	_state._world = newWorld;
	_state._start = newStart;
	_state._anims = new Array();
	_state._playerdir = DirUtil.LEFT;
	_state._player = new Coord(0, 0);

	_state._playerdead = true;
	_state._playerlocked = false;
    }

    public function update():Void {
	if (!_state._editmode) {
	    if (_state._editmodemsgs.length > 0) {
		_state._editmodemsgs = new List();
	    }
	    return;
	}

	var activeLevelPath = _state._levelpaths[_state._activelevelnum - 1];
	while (_state._editmodemsgs.length > 0) {
	    var msg = _state._editmodemsgs.pop();

	    switch (msg) {
	    case NextTile:
		_editTileCyclePos = (_editTileCyclePos + 1) % EditTileCycle.length;
		_state._editmodetile = EditTileCycle[_editTileCyclePos];
	    case PrevTile:
		_editTileCyclePos = (_editTileCyclePos + EditTileCycle.length - 1) % EditTileCycle.length;
		_state._editmodetile = EditTileCycle[_editTileCyclePos];
	    case PutTile:
		_state._world[_state._editmodetilepos] = _state._editmodetile;
	    case CopyTile:
		_state._editmodetile = _state._world[_state._editmodetilepos];
	    case NextLevel:
		if (_state._activelevelnum < _state._levelpaths.length) {
		    loadLevel(_state._activelevelnum + 1);
		}
	    case PrevLevel:
		if (_state._activelevelnum > 1) {
		    loadLevel(_state._activelevelnum - 1);
		}
	    case WriteLevel:
		RcLib.assert(!_state._loadlevelsfromassets);
		
		var txt:String = "";
		for (i in 0 ... _state._world.length) {

		    if (i % _state._width == 0 && i != 0) {
			txt = txt + "\n";
		    }

		    var tile = _state._world[i];
		    var found = false;
		    for (rec in Tilesyms) {
			if (rec.tile == tile) {
			    txt = txt + rec.sym;
			    found = true;
			    break;
			}
		    }

		    if (!found) {
			txt = txt + "0";
			trace("unknown tile: " + tile);
		    }
		}
		//File.saveContent(activeLevelPath, txt);
	    default:
	    }
	}
    }

    public function writeLevel(path:String):Void {
	
    }
}
