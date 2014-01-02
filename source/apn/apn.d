module apn.apn;

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
	APNConnection	m_connection;
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

		m_connection = new APNConnection(m_options);
	}

	/++
	 + Pushes out a single notification to a single device target.
	 + 
	 + Params:
	 + 	_msg	= the message
	 + 	_device	= the target device token
	 +/
	void pushNotification(APNNotification _msg, string _device)
	{
		auto binNotify = m_notifications.pop();

		binNotify.update(_msg,m_notificationId++,_device);

		m_connection.send(binNotify);
	}

	///
	private static BinaryNotification createNewNotification()
	{
		return new BinaryNotification();
	}
}