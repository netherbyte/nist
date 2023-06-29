package com.netherbyte.nist;

import haxe.ds.ArraySort;
import haxe.Log;
import haxe.Json;
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
		if (!path.contains(".")) {
			path = path + "/index.html";
		}
		var fspath = Path.join([Sys.getCwd(), "/public/" + path]);

		if (path == "issue.hx") {
			var data = req.postData.split("&");

			var issue:Issue = {
				number: "",
				assignees: [],
				reporter: "",
				status: "Open",
				versionsAffected: [],
				updates: [[]],
				createdOn: Math.round(Date.now().getTime()),
				description: "",
				name: ""
			};

			for (d in data) {
				var kv = d.split("=");
				switch(kv[0]) {
					case "name":
						issue.name = kv[1];
					case "desc":
						issue.description = kv[1];
					case "1":
						issue.versionsAffected.push("a1.0.0");
					case "2":
						issue.versionsAffected.push("a1.1.0");
				}
			}

			Database.addIssue(issue);

			req.close();
		}

		if (FileSystem.exists(fspath) && !FileSystem.isDirectory(fspath)) {
			var content = File.getContent(fspath);

			var replaced = content;
			for (i in 0...replacementsK.length) {
				var k = replacementsK[i];
				var v = replacementsV[i];

				if (!replaced.contains("${" + k + "}"))
					continue;

				replaced = content.replace("${" + k + "}", v);
			}

			// now we will have to detect if the user is trying to access an issue page and then provide the replacements for the issue
			if (params[0] != "") {
				// this means that there is a url parameter
				var kv = params[0].split("=");
				switch (kv[0]) {
					case "issue":
						var project = path.split("/")[0];
						var pagepath = Path.join([Sys.getCwd(), "/public/" + project + "/issue.html"]);
						var issuepath = Path.join([Sys.getCwd(), "/db/" + project + "/" + kv[1] + ".json"]);

						var content = File.getContent(pagepath);

						var replaced = content;
						for (i in 0...replacementsK.length) {
							var k = replacementsK[i];
							var v = replacementsV[i];

							if (!replaced.contains("${" + k + "}"))
								continue;

							replaced = replaced.replace("${" + k + "}", v);
						}
						// now replace the issue json
						var issue:Issue = Json.parse(File.getContent(issuepath));
						var irk = [
							"issue.number",
							"issue.name",
							"issue.status",
							"issue.description",
							"issue.versions",
							"issue.createdOn",
							"issue.lastUpdate",
							"issue.reporter"
						];
						var irv = [
							issue.number,
							issue.name,
							issue.status,
							issue.description,
							issue.versionsAffected.toString(),
							issue.createdOn + "",
							issue.updates[issue.updates.length - 1][1],
							issue.reporter
						];
						irk.push("issue.versionsLI");
						var versionsLI = "";
						for (i in issue.versionsAffected) {
							versionsLI = versionsLI + "<li>" + i + "</li>";
						}
						irv.push(versionsLI);
						irk.push("issue.assigneesLI");
						var assigneesLI = "";
						for (i in issue.assignees) {
							assigneesLI = assigneesLI + "<li>" + i + "</li>";
						}
						irv.push(assigneesLI);

						irk.push("issue.statusIndicator");
						switch (issue.status) {
							case "Open": irv.push("🔴");
							case "Acknowledged": irv.push("🟠");
							case "In Progress": irv.push("🟡");
							case "Closed": irv.push("⚪️");
							case "Fixed": irv.push("🟢");
						}

						var ir = replaced;
						for (i in 0...irk.length) {
							var k = irk[i];
							var v = irv[i];

							ir = ir.replace("${" + k + "}", v);
						}

						req.replyData(ir, "text/html", 200);
				}
			} else {
				if (content.contains("${isumpage")) {
					var isumpageln = content.split("\n")[0];
					var isumpage = isumpageln.substring(12, isumpageln.length - 3).toLowerCase();

					trace(isumpage);

					var repl = "";
					var keys = "${" + isumpage + "_issuecTR}";

					var issues = Database.getIssues(isumpage);
					issues.sort((a, b) -> Std.parseInt(a.number.substring(3)) - Std.parseInt(b.number.substring(3)));
					for (i in 0...(issues.length)) {
						var issue = issues[i];
						repl += "
						<tr>
						<td>"
							+ issue.number
							+ "</td>
						<td>"
							+ issue.name
							+ "</td>
							<td>"
							+ issue.status
							+ "</td>
						";
					}

					trace(repl);

					replaced = replaced.replace("${isumpage " + isumpage + "}", "");
					replaced = replaced.replace(keys, repl);
				}
				req.replyData(replaced, "text/html", 200);
			}
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
