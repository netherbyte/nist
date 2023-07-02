package com.netherbyte.nist;

class Main {
	public static function main() {
		Server.addReplacement("domain", "localhost:3000");
		Server.addReplacement("commonFooter", "<p>Nist is open-source software licensed under GNU GPL v3.0. <a
					href=\" https: // github.com/netherbyte/nist\">https://github.com/netherbyte/nist</a></p>");
		Server.addReplacement("mfIH", "<button onclick='window.location.href = \"../\"'>Back</button>");
		Server.addReplacement("mfIF", "");
		// the header is gonna be a back button or something
		// i can make it read from an html file
		Sys.println("Creating HTTP server");
		Server.start("0.0.0.0");
	}
}
