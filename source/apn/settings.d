module apn.settings;

/// settings to configurate connections to APN
struct APNSettings
{
	/// certificate file
	string cert = "cert.pem";

	/// key file
	string key = "key.pem";

	/// gateway to connect to
	string address = "gateway.push.apple.com";

	/// port to connect to
	ushort port = 2195;

	/// max concurrent connections to APN
	int maxConnections = 1;
}