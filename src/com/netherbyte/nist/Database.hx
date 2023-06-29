package com.netherbyte.nist;

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
}
