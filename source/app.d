import std.stdio;

import apn.apn;

shared static this()
{
	APNConnection.Options options = {address: "gateway.sandbox.push.apple.com"};

    auto apnConnection = new APNConnection(options);

	auto note = new APNNotification();

	//note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
	//note.badge = 3;
	//note.sound = "ping.aiff";
	//note.alert = "\uD83D\uDCE7 \u2709 You have a new message";
	//note.payload = ["messageFrom": "Caroline"];

	apnConnection.pushNotification(note, ["<device token>"]);
}
