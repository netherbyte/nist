package com.netherbyte.nist;

import haxe.extern.EitherType;

typedef Issue = {
	number:String,
	name:String,
	description:String,
	createdOn:Int,
	updates:Array<Array<EitherType<Int, String>>>,
	versionsAffected:Array<String>,
	status:String,
	reporter:String,
	assignees:Array<String>
}
