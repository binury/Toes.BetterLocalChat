using System.Text.Json.Serialization;

namespace BetterLocalChat;

public class ConfigFileSchema
{
	[JsonInclude]
	public bool infiniteChatRange = false;
	[JsonInclude]
	public bool silentCommandMessages = true;
}
