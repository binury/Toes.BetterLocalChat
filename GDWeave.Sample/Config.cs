using System.Text.Json.Serialization;

namespace BetterLocalChat;

public class Config(ConfigFileSchema configFile)
{
	[JsonInclude]
	public bool infiniteChatRange = configFile.infiniteChatRange;
}
