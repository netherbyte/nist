package com.netherbyte.nist;

import haxe.extern.EitherType;

typedef Issue = {
	number:String,
	name:String,
	description:String,
	createdOn:Float,
	updates:Array<Array<EitherType<Float, String>>>,
	versionsAffected:Array<String>,
	status:String,
	reporter:String,
	assignees:Array<String>
}
