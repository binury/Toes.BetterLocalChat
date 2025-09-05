using System.Text.Json.Serialization;

namespace BetterLocalChat;

public class ConfigFileSchema
{
	// Using server commands like `!kick player` will be sent silently without emitting speech or a chat bubble.
	[JsonInclude]
	public bool silentCommandMessages = true;

	// 1: Alt sound
	// 2: Aol Instant Messenger Sound
	[JsonInclude]
	public int messageSound = 2;

	// Flash window (if in background) when your name is mentioned in chat
	[JsonInclude]
	public bool notifyOnMention = true;

	// Play messageSound when your name is mentioned in chat
	[JsonInclude]
	public bool soundOnMention = true;

	// Flash window (if in background) whenever a player sends a message
	[JsonInclude]
	public bool notifyOnMessage = false;

	// Play messageSound whenever a player sends a message
	[JsonInclude]
	public bool soundOnMessage = false;

	[JsonInclude]
	public bool infiniteChatRange = false;

}
