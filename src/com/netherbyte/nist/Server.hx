package com.netherbyte.nist;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import hx_webserver.HTTPRequest;
import hx_webserver.HTTPServer;

using StringTools;

class Server {
	public static var server:HTTPServer;
	public static var replacementsK = [];
	public static var replacementsV = [];

	public static function addReplacement(key:String, value:String) {
		replacementsK.push(key);
		replacementsV.push(value);
	}

	public static function create() {
		if (Sys.args().contains("--dev")) {
			server = new HTTPServer("0.0.0.0", 3000, true);
			Sys.println("Listening on port 3000");
		} else {
			server = new HTTPServer("0.0.0.0", 443, true);
			Sys.println("Listening on port 443");
		}
		server.onClientConnect = (d:HTTPRequest) -> handleRequest(d);
	}

	public static function handleRequest(req:HTTPRequest) {
		var path = req.methods[1].substring(1).split("?")[0];
		var params = req.methods[1].substring(1).split("?")[1].split("&");
		if (!path.endsWith(".html")) {
			path = path + "/index.html";
		}
		var fspath = Path.join([Sys.getCwd(), "/public/" + path]);

		if (FileSystem.exists(fspath) && !FileSystem.isDirectory(fspath)) {
			final content = File.getContent(fspath);

			var replaced = content;
			for (i in 0...replacementsK.length) {
				var k = replacementsK[i];
				var v = replacementsV[i];

				replaced = content.replace("${" + k + "}", v);
			}

			req.replyData(replaced, "text/html", 200);
		} else if (FileSystem.exists(Path.join([Sys.getCwd(), "/public/404.html"]))) {
			final content = File.getContent(Path.join([Sys.getCwd(), "/public/404.html"]));
			var replaced = content;
			for (i in 0...replacementsK.length) {
				var k = replacementsK[i];
				var v = replacementsV[i];

				replaced = content.replace("${" + k + "}", v);
			}

			req.replyData(replaced, "text/html", 404);
		} else {
			req.replyData("404 This file doesn't exist or has ben moved", "text/plain", 404);
		}
	}
}
