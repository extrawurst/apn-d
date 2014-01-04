module apn.apn;

import vibe.d;

import apn.connection;
import apn.binarynotification;
public import apn.settings;
public import apn.notification;

///
class ObjectPool(T, alias Func)
{
	private T[] m_list;

	///
	public T pop()
	{
		if(m_list.length > 0)
		{
			T result = m_list[$-1];
			m_list.length = 0;
			return result;
		}

		return Func();
	}

	///
	public void push(T _obj)
	{
		m_list ~= _obj;
	}
}

///
class APNSystem
{
	private immutable APNSettings	m_options;

private:
	alias ObjectPool!(BinaryNotification, createNewNotification) Notifications;

	int				m_notificationId;
	APNConnection[]	m_connections;
	Notifications	m_notifications = new Notifications();

public:

	/++
	 + constructor
	 + 
	 + Params:
	 + 	_options	= configuration
	 +/
	this(APNSettings _options)
	{
		m_options = _options;

		foreach(i; 0..m_options.maxConnections)
		{
			auto newConn = new APNConnection(m_options);
			m_connections ~= newConn;
		}
	}

	/++
	 + Pushes out a single notification to a single device target.
	 + 
	 + Params:
	 + 	_msg	= the message
	 + 	_device	= the target device token
	 +/
	void pushNotification(APNNotification _msg, ubyte[] _device)
	{
		auto binNotify = m_notifications.pop();

		binNotify.update(_msg, m_notificationId++, _device);

		auto connection = getConnection();

		connection.send(binNotify);
	}

private:

	///
	APNConnection getConnection()
	{
		foreach(conn; m_connections)
		{
			if(!conn.isBusy)
				return conn;
		}

		if(m_connections.length < m_options.maxConnections)
		{
			auto newConn = new APNConnection(m_options);

			m_connections ~= newConn;

			logInfo("new connection created");

			return newConn;
		}

		// wait for signal here
		int i=0;
		while(true)
		{
			if(!m_connections[i].isBusy)
				return m_connections[i];

			i++;
			if(i >= m_connections.length)
				i=0;

			sleep(10.msecs);
		}
	}

	///
	static BinaryNotification createNewNotification()
	{
		return new BinaryNotification();
	}
}