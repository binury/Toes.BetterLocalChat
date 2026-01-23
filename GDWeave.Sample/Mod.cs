using GDWeave;
using util.LexicalTransformer;

namespace BetterLocalChat;

public class Mod : IMod
{
	private const string modName = "BetterLocalChat";

	public Mod(IModInterface mi)
	{
		var config = new Config(mi.ReadConfig<ConfigFileSchema>());

		mi.RegisterScriptMod(
			new TransformationRuleScriptModBuilder()
				.ForMod(mi)
				.Named(modName + ": local chat shortcut command")
				.Patching("res://Scenes/HUD/playerhud.gdc")
				.AddRule(
					new TransformationRuleBuilder()
						.Named("Add new local flag")
						.Do(Operation.Append)
						.Matching(
							TransformationPatternFactory.CreateGdSnippetPattern(
								"""
								var current_effect = "none"
								"""
							)
						)
						.With(
							"""

							var local_shortcut = false

							""",
							1
						)
				)
				.AddRule(
					new TransformationRuleBuilder()
						.Named("Add /l shortcut")
						.Do(Operation.Append)
						.Matching(
							TransformationPatternFactory.CreateGdSnippetPattern(
								"""
								"/wag": PlayerData.emit_signal("_wag_toggle")
								"""
							)
						)
						.With(
							"""

							"/l": local_shortcut = true

							""",
							4
						)
				)
				.AddRule(
					new TransformationRuleBuilder()
						.Named("Amend `local` conditional to include check for local_shortcut")
						.Do(Operation.ReplaceAll)
						.Matching(
							TransformationPatternFactory.CreateGdSnippetPattern(
								"Network._send_message(final, final_color, chat_local)"
							)
						)
						.With("Network._send_message(final, final_color, chat_local or local_shortcut)")
				)
				.Build()
		);

		mi.RegisterScriptMod(
			new TransformationRuleScriptModBuilder()
				.ForMod(mi)
				.Named(modName + ": (Enhancements)")
				.Patching("res://Scenes/Singletons/SteamNetwork.gdc")
				.AddRule(
					new TransformationRuleBuilder()
						.Named("Remove redundant & ugly local prefix")
						.Do(Operation.ReplaceAll)
						.Matching(
							TransformationPatternFactory.CreateGdSnippetPattern(
								""" "[color=#a4756a][​local​] [/color]" """
							)
						)
						.With("\"\"")
				)
				.AddRule(
					new util.LexicalTransformer.TransformationRuleBuilder()
						.Named("Print local chat (with prefix) under global tab too")
						.Do(Operation.Append)
						.When(!config.infiniteChatRange)
						.Matching(
							TransformationPatternFactory.CreateGdSnippetPattern(
								"""
								if dist < 25.0: _recieve_safe_message(user_id, user_color, user_message, true)
								"""
							)
						)
						.With(
							"""

							 if dist < 25.0: _recieve_safe_message(user_id, user_color, "(local) " + user_message, false)

							""",
							6
						)
				)
				.AddRule(
					new util.LexicalTransformer.TransformationRuleBuilder()
						.Named("Infinite local chat range limit")
						.Do(Operation.Append)
						.When(config.infiniteChatRange)
						.Matching(
							TransformationPatternFactory.CreateGdSnippetPattern(
								"""
								elif DATA["local"]:
								"""
							)
						)
						.With(
							"""

							_recieve_safe_message(user_id, user_color, "(local) " + user_message, false)

							""",
							6
						)
				)
				.AddRule(
					new util.LexicalTransformer.TransformationRuleBuilder()
						.Named("Infinite local chat range limit 2")
						.Do(Operation.Append)
						.When(config.infiniteChatRange)
						.Matching(
							TransformationPatternFactory.CreateGdSnippetPattern(
								"""
								if dist < 25.0: _recieve_safe_message(user_id, user_color, user_message, true)
								"""
							)
						)
						// This approach is less intrusive/more compatible than changing the conditional!
						.With(
							"""

							if dist >= 25.0: _recieve_safe_message(user_id, user_color, user_message, true)

							""",
							6
						)
				)
				.Build()
		);

		mi.RegisterScriptMod(
			new TransformationRuleScriptModBuilder()
				.ForMod(mi)
				.Named(modName + ": (Enhancements 2)")
				.Patching("res://Scenes/Entities/Player/player.gdc")
				.AddRule(
					new TransformationRuleBuilder()
						.Named("Silently transmit server command messages (when prefixed by !)")
						.Do(Operation.Append)
						.Matching(
							TransformationPatternFactory.CreateFunctionDefinitionPattern("_message_sent", ["text"])
						)
						.When(config.silentCommandMessages)
						.With(
							"""

							if text.begins_with("!") and text.count("!") == 1: return

							""",
							1
						)
				)
				.Build()
		);

		mi.RegisterScriptMod(
			new TransformationRuleScriptModBuilder()
				.ForMod(mi)
				.Named("YapBack - Network Patch")
				.Patching("res://Scenes/Singletons/SteamNetwork.gdc")
				.AddRule(
					new TransformationRuleBuilder()
						.Named("Line number override")
						.Matching(TransformationPatternFactory.CreateGdSnippetPattern("var max_chat_length = 128"))
						.With("+ 3968", 1)
				)
				.Build()
		);

		mi.RegisterScriptMod(
			new TransformationRuleScriptModBuilder()
				.ForMod(mi)
				.Named("YapBackk - PlayerHud Patches")
				.Patching("res://Scenes/HUD/playerhud.gdc")
				.AddRule(
					new TransformationRuleBuilder()
						.Named("Scroll bar restore")
						.Matching(
							TransformationPatternFactory.CreateGdSnippetPattern("gamechat.scroll_active = using_chat")
						)
						.With(
							"""

							gamechat.scroll_active = chat_timer > 0

							""",
							1
						)
				)
				.AddRule(
					new TransformationRuleBuilder()
						.Named("Auto scroll pause")
						.Matching(
							TransformationPatternFactory.CreateGdSnippetPattern(
								"chat.placeholder_text = \"Type to chat!\""
							)
						)
						.With(
							"""

							gamechat.scroll_following = false

							""",
							4
						)
				)
				.AddRule(
					new TransformationRuleBuilder()
						.Named("Auto scroll resume")
						.Matching(TransformationPatternFactory.CreateGdSnippetPattern("chat.selecting_enabled = false"))
						.With(
							"""

							gamechat.scroll_following = true
							gamechat.scroll_to_line(gamechat.get_line_count() - 1)

							""",
							1
						)
				)
				.AddRule(
					new TransformationRuleBuilder()
						.Named("Extend chat fade timeout")
						.Matching(TransformationPatternFactory.CreateGdSnippetPattern("chat_timer = 30"))
						.With(
							"""

							chat_timer = 60

							""",
							2
						)
				)
				.Build()
		);
	}

	public void Dispose()
	{
		// Post-injection cleanup (optionalTransformationPatternFactory.CreateGdSnippetPattern)
	}
}
