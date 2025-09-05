using System.Text.Json.Serialization;

namespace BetterLocalChat;

public class Config(ConfigFileSchema configFile)
{
	[JsonInclude]
	public bool silentCommandMessages = configFile.silentCommandMessages;
	[JsonInclude]
	public int messageSound = configFile.messageSound;
	[JsonInclude]
	public bool notifyOnMention = configFile.notifyOnMention;
	[JsonInclude]
	public bool soundOnMention = configFile.soundOnMention;
	[JsonInclude]
	public bool notifyOnMessage = configFile.notifyOnMessage;
	[JsonInclude]
	public bool soundOnMessage = configFile.soundOnMessage;
	[JsonInclude]
	public bool infiniteChatRange = configFile.infiniteChatRange;

}
