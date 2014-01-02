module apn.binarynotification;

import std.array;
import std.bitmanip;

import apn.notification;

import vibe.d:logInfo;

align(1) struct FrameHeader
{
	align(1):
	ubyte command;
	ubyte[4] frameLength;
}

align(1) struct ItemHeader
{
	align(1):
	ubyte itemId;
	ubyte[2] itemDataLength;
}

align(1) struct NotificationEnd
{
	align(1):
	uint id;
	uint expiration;
	ubyte priority;
}

///
class BinaryNotification
{
	ubyte[] m_data;
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

		auto itemDataLength = cast(ushort)(_device.length + payload.length + NotificationEnd.sizeof);
		auto frameLength = ItemHeader.sizeof + itemDataLength;
		m_data.length = FrameHeader.sizeof + frameLength;

		FrameHeader* frameHeader = cast(FrameHeader*)&m_data[0];
		frameHeader.command = 2;
		frameHeader.frameLength = nativeToBigEndian(frameLength);
		
		ItemHeader* itemHeader = cast(ItemHeader*)&m_data[FrameHeader.sizeof];
		itemHeader.itemId = 0;
		itemHeader.itemDataLength = nativeToBigEndian(itemDataLength);
		
		auto idStart = FrameHeader.sizeof + ItemHeader.sizeof;
		auto idEnd = idStart + 32;
		
		m_data[idStart..idEnd] = _device[];
		
		auto payloadStart = idEnd;
		auto payloadEnd = payloadStart + payload.length;
		m_data[payloadStart..payloadEnd] = (cast(ubyte[])payload)[];
		
		NotificationEnd* notifyEnd = cast(NotificationEnd*)&m_data[payloadEnd];
		notifyEnd.id = _id;
		notifyEnd.expiration = 0;
		notifyEnd.priority = 10;

		logInfo("data: '%s'", m_data);

		//auto buffer = appender!(const ubyte[])();
		//buffer.append!ubyte(2);				//command
		//buffer.append!uint(frameLength);
		//
		//buffer.put(_device);
		//
		//m_data = buffer.data;
	}
}