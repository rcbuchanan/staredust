package;

class RcLib {
    public static function assert(cond:Bool) {
	if (!cond) {
	    trace("uh-oh!");
	    throw "Assertion failed!";
	}
    }
}
