module apn.notification;

import vibe.d;

///
struct APNNotification
{
	///
	enum Priority {
		Prio10,
		Prio5
	}

	///
	Json alert;

	///
	string sound;

	///
	bool contentAvailable = false;

	///
	int badge = -1;

	///
	Json payload;

	///
	Priority priority;

	///
	int expiration;

	///
	string payloadToString()
	{
		Json item = payload.type == Json.Type.undefined ? Json.emptyObject : payload;

		if(payload.type == Json.Type.object && payload.aps.type != Json.Type.undefined)
			throw new Exception("custom payload must not contain 'aps' key");

		item.aps = Json.emptyObject;

		if(alert.type != Json.Type.undefined &&
		   alert.type != Json.Type.string && 
		   alert.type != Json.Type.object)
			throw new Exception("alert is malformed");

		if(alert.type != Json.Type.undefined)
			item.aps.alert = alert;

		if(sound.length > 0)
			item.aps.sound = sound;

		if(badge >= 0)
			item.aps.badge = badge;

		return item.toString();
	}
}