package com.netherbyte.nist;

import haxe.Json;
import sys.io.File;
import haxe.io.Path;
import haxe.io.Bytes;

using StringTools;

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
		// trace(issues);
		return issues;
	}

	public static function addIssue(issue:Issue, project:String, pid:String) {
		trace("here");
		var db = File.getContent(Path.join([Sys.getCwd(), "db/issues.db"]));
		var count = 0;
		for (i in db.split("\n")) {
			trace("here");
			var v = i.split(":");
			trace(v);
			if (v[0].toLowerCase() == project.toLowerCase()) {
				count = Std.parseInt(v[1]);
				trace("here");
			}
		}
		count += 1;
		trace("here");
		var a = issue;
		a.number = pid + "-" + count;
		var savecontent = Json.stringify(a);
		trace("here");

		var name = issue.number.split("-")[1];
		trace("here");
		File.saveContent(Path.join([Sys.getCwd(), "db/" + project, name + ".json"]), savecontent);
		// trace(issue);

		var newdb = db.replace(project.toLowerCase() + ":" + (count - 1), project.toLowerCase() + ":" + (count));
		File.saveContent(ISSUES_DB, newdb);
	}
}
