package com.netherbyte.nist;

import haxe.io.Bytes;
import haxe.crypto.Sha512;

class Authentication {
	public static function registerUser(username:String, password:String) {
		var pwdHash = Sha512.make(Bytes.ofString(password));
		var usrBytes = Bytes.ofString(username);
		Database.append(Bytes.ofHex(usrBytes.toHex() + "0A" + pwdHash.toHex()), 1);
	}
}
