module apn.binarynotification;

import apn.notification;

align(1) struct FrameHeader
{
	ubyte command;
	int frameLength;
}

align(1) struct ItemHeader
{
	ubyte itemId;
	ushort itemDataLength;
}

align(1) struct NotificationEnd
{
	int id;
	int expiration;
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
	void update(APNNotification _notification, int _id, string _device)
	{
		m_id = _id;

		auto payload = _notification.payloadToString();
		assert(payload.length <= 256);

		auto itemDataLength = cast(ushort)(payload.length + 32 + payload.length + 32 + NotificationEnd.sizeof);
		auto frameLength = ItemHeader.sizeof + itemDataLength;
		m_data.length = FrameHeader.sizeof + frameLength;

		FrameHeader* frameHeader = cast(FrameHeader*)&m_data[0];
		frameHeader.command = 2;
		frameHeader.frameLength = frameLength;

		ItemHeader* itemHeader = cast(ItemHeader*)&m_data[3];
		itemHeader.itemId = 0;
		itemHeader.itemDataLength = itemDataLength;

		auto payloadStart = FrameHeader.sizeof + ItemHeader.sizeof;
		auto payloadEnd = payloadStart + payload.length;
		m_data[payloadStart..payloadEnd] = (cast(ubyte[])payload)[];

		NotificationEnd* notifyEnd = cast(NotificationEnd*)&m_data[payloadEnd];
		notifyEnd.id = _id;
		notifyEnd.expiration = 0;
		notifyEnd.priority = 10;
	}
}