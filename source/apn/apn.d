module apn.apn;

import vibe.core.log;
import vibe.core.net;
import vibe.stream.ssl;

///
class APNNotification
{
}

///
class APNConnection
{
private:
	Options m_options;

public:

	struct Options
	{
		string cert = "cert.pem";
		string key = "key.pem";
		string address = "gateway.push.apple.com";
		ushort port = 2195;
	}

	///
	this(Options _options)
	{
		m_options = _options;

		connect();
	}

	///
	void pushNotification(APNNotification _msg, string[] _devices)
	{

	}

private:

	///
	void connect()
	{
		auto conn = connectTCP(m_options.address, m_options.port);
		logInfo("tcp connected");

		auto sslctx = new SSLContext(SSLContextKind.client);
		sslctx.useCertificateChainFile(m_options.cert);
		sslctx.usePrivateKeyFile(m_options.key);
		auto stream = new SSLStream(conn, sslctx, SSLStreamState.connecting);

		logInfo("ssl enabled");

		//stream.write("Hello, World!");

		stream.finalize();
		conn.close();

		logInfo("yeah");
	}
}