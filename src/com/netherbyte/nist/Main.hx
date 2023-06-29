package com.netherbyte.nist;

class Main {
	public static function main() {
		Server.addReplacement("domain", "localhost:3000");
		Server.addReplacement("commonFooter", "<p>Nist is open-source software licensed under GNU GPL v3.0. <a
					href=\" https: // github.com/netherbyte/nist\">https://github.com/netherbyte/nist</a></p>");
		Sys.println("Creating HTTP server");
		Server.create();
	}
}
