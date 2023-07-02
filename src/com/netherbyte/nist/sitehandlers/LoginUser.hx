package com.netherbyte.nist.sitehandlers;

import sys.io.File;
import haxe.io.Path;
import hx_webserver.HTTPRequest;
import com.netherbyte.nist.Server.*;

using StringTools;

class LoginUser extends SiteHandler {
	public static function execute(req:HTTPRequest, path:String, params:Array<String>) {
		var data = req.postData.split("&");

		var username = "";
		var password = "";

		for (param in data) {
			if (param.split("=")[0] == "username") {
				username = param.split("=")[1];
			} else if (param.split("=")[0] == "password") {
				password = param.split("=")[1];
			}
		}

		if (Authentication.verifyUser(username, password)) {
			// send user to home page
			var fspath = Path.join([Sys.getCwd(), "/public/index.html"]);
			var content = File.getContent(fspath);

			var replaced = content;
			for (i in 0...replacementsK.length) {
				var k = replacementsK[i];
				var v = replacementsV[i];

				if (!replaced.contains("${" + k + "}"))
					continue;

				replaced = content.replace("${" + k + "}", v);
			}

			req.replyData(replaced, "text/html", 200);
		} else {
			// send incorrect password message
			var fspath = Path.join([Sys.getCwd(), "/public/account/login.html"]);
			var content = File.getContent(fspath);

			var replaced = content;
			for (i in 0...replacementsK.length) {
				var k = replacementsK[i];
				var v = replacementsV[i];

				if (!replaced.contains("${" + k + "}"))
					continue;

				replaced = content.replace("${" + k + "}", v);
			}
			replaced = replaced.replace("<form", "<p>Incorrect username or password</p><br><form");

			req.replyData(replaced, "text/html", 200);
		}
	}
}
