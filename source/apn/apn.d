module apn.apn;

import vibe.core.core;
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
	Options			m_options;
	TCPConnection	m_tcp;
	SSLStream		m_sslStream;
	ubyte[]			m_receiveBuff;

public:

	///
	@property bool isConnected() const {return m_sslStream !is null && m_tcp !is null;}

	///
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
	void shutdown()
	{
		m_sslStream.finalize();
		m_tcp.close();

		m_tcp = null;
		m_sslStream = null;
	}

	///
	void pushNotification(APNNotification _msg, string[] _devices)
	{
		
	}

private:

	///
	void connect()
	{
		m_tcp = connectTCP(m_options.address, m_options.port);

		auto sslctx = new SSLContext(SSLContextKind.client);
		sslctx.useCertificateChainFile(m_options.cert);
		sslctx.usePrivateKeyFile(m_options.key);

		m_sslStream = new SSLStream(m_tcp, sslctx);

		logInfo("connected");

		runTask(&receive);

		runTask((){
			logInfo("start sending");

			while(isConnected)
			{
				tryWrite("foo");
				
				logInfo("wrote");

				yield();
			}
		});
	}

	///
	void tryWrite(T)(T _data)
	{
		try m_sslStream.write(_data);
		catch(Exception e)
		{
			logError("writing error: %s",e);

			shutdown();
		}
	}

	///
	void receive()
	{
		scope(failure) 
		{
			logInfo("[apn] received -> shutdown");

			shutdown();

			yield();
		}

		logInfo("start receiving");

		while(isConnected)
		{
			if(m_sslStream.dataAvailableForRead)
			{
				m_receiveBuff.length = cast(uint)m_sslStream.leastSize();
				
				m_sslStream.read(m_receiveBuff);

				logError("got data: %s",m_receiveBuff);

				throw new Exception("apn just sends data if there was something wrong");
			}

			//logInfo("tried reveice");

			yield();
		}
	}
}