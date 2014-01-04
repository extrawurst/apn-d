module apn.binarynotification;

import std.array;
import std.bitmanip;

import apn.notification;

import vibe.d:logInfo;

///
class BinaryNotification
{
	const(ubyte)[] m_data;
	int m_id;

	///
	@property const(ubyte[]) data() const { return m_data; }
	///
	@property int id() const { return m_id; }

	///
	void update(APNNotification _notification, int _id, ubyte[] _device)
	{
		m_id = _id;

		auto payload = _notification.payloadToString();
		assert(payload.length <= 256);

		auto frameLength = _device.length + payload.length + (4*3) + 9;

		auto buffer = appender!(const ubyte[])();

		//frame header
		buffer.append!ubyte(2);				//command
		buffer.append!uint(frameLength);
		
		//items

		buffer.append!ubyte(1);
		buffer.append!ushort(32);
		buffer.put(_device);

		buffer.append!ubyte(2);
		buffer.append!ushort(cast(ushort)payload.length);
		buffer.put(cast(ubyte[])payload);

		buffer.append!ubyte(3);
		buffer.append!ushort(4);
		buffer.append!uint(_id);

		buffer.append!ubyte(4);
		buffer.append!ushort(4);
		buffer.append!uint(_notification.expiration);

		buffer.append!ubyte(5);
		buffer.append!ushort(1);
		buffer.append!ubyte(_notification.priority==APNNotification.Priority.Prio10 ? 10 : 5);
		
		m_data = buffer.data;
	}
}