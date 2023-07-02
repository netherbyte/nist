package com.netherbyte.nist;

import hx_webserver.HTTPRequest;

abstract class SiteHandler {
	public static function execute(req:HTTPRequest, path:String, params:Array<String>):Void {}
}
