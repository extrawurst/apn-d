import std.stdio;

import apn.apn;
import vibe.appmain;

shared static this()
{
	APNSettings settings = {
		address: "gateway.sandbox.push.apple.com",
		maxConnections: 1,
	};

    auto apn = new APNSystem(settings);

	auto note = APNNotification();

	//note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
	//note.badge = 3;
	//note.sound = "ping.aiff";
	note.alert = "You have a new message";
	//note.payload = ["messageFrom": "Caroline"];

	apn.pushNotification(note, "<device token>");
}
