module apn.settings;

///
struct APNSettings
{
	string cert = "cert.pem";
	string key = "key.pem";
	string address = "gateway.push.apple.com";
	ushort port = 2195;
	int maxConnections = 1;
}