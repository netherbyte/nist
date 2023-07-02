package com.netherbyte.nist.sitehandlers;

import hx_webserver.HTTPRequest;

class Issue extends SiteHandler {
	public static function execute(req:HTTPRequest, path:String, params:Array<String>) {
		trace(req.postData);
		var data = req.postData.split("&");

		var issue:com.netherbyte.nist.Issue = {
			number: "",
			assignees: [],
			reporter: "iguana",
			status: "Open",
			versionsAffected: [],
			updates: [[]],
			createdOn: Sys.time(),
			description: "",
			name: ""
		};

		var project = params[0].substr(8);
		var pid = "";

		for (d in data) {
			var kv = d.split("=");
			trace(kv);
			switch (kv[0]) {
				case "\nname":
					issue.name = kv[1];
					trace(issue.name);
				case "desc":
					issue.description = kv[1];
					trace("here");
				case "1":
					issue.versionsAffected.push("a1.0.0");
					trace("here");
				case "2":
					issue.versionsAffected.push("a1.1.0");
					trace("here");
			}
		}

		switch (project) {
			case "Microfacture":
				pid = "MF";
		}

		Database.addIssue(issue, project, pid);

		req.replyData("Issue Reported", "text/plain", 200);
		return;
	}
}
