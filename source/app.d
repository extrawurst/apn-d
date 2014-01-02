module app;

import std.stdio;
import std.base64;

import apn.apn;
import vibe.d;

shared static this()
{
	APNSettings settings = {
		address: "gateway.sandbox.push.apple.com",
		maxConnections: 1,
	};

    auto apn = new APNSystem(settings);

	auto note = APNNotification();

	//note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
	note.badge = 3;
	//note.sound = "ping.aiff";
	note.alert = "You have a new message";
	//note.payload = ["messageFrom": "Caroline"];

	auto device = Base64.decode("ggBlTEDkPywow4TbHYlbTEDodSsKcbeSuWXtbKfGynU=");

	//logInfo("token(%s): '%s'", device.length, device);

	apn.pushNotification(note, device);
}
