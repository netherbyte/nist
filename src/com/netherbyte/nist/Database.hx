package com.netherbyte.nist;

import haxe.Json;
import sys.io.File;
import haxe.io.Path;
import haxe.io.Bytes;

class Database {
	public static final ISSUES_DB = Path.join([Sys.getCwd(), "db/issues.db"]);
	public static final USERS_DB = Path.join([Sys.getCwd(), "db/users.db"]);

	public static function append(data:Bytes, db:Int) {
		switch (db) {
			case 0:
				var file = File.getBytes(ISSUES_DB).toHex();
				File.saveBytes(ISSUES_DB, Bytes.ofHex(file + Bytes.ofString("\n").toHex() + data.toHex()));
			case 1:
				var file = File.getBytes(USERS_DB);
				File.saveBytes(USERS_DB, Bytes.ofHex(file + Bytes.ofString("\n").toHex() + data.toHex()));
		}
	}

	public static function getIssues(project:String):Array<Issue> {
		var db = File.getContent(ISSUES_DB).split("\n");
		var issuesCount = 0;
		for (line in db) {
			var d = line.split(":");
			if (d[0] == project) {
				issuesCount = Std.parseInt(d[1]);
			}
		}
		var issues = [];
		trace(issuesCount);
		for (i in 1...(issuesCount + 1)) {
			trace(Path.join([Sys.getCwd(), "db/" + project, i + ".json"]));
			var file:Issue = Json.parse(File.getContent(Path.join([Sys.getCwd(), "db/" + project, i + ".json"])));
			issues.push(file);
			trace(issues.length);
		}
		trace(issues);
		return issues;
	}
}
