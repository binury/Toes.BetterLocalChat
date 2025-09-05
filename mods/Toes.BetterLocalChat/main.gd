########################
## copyright 2025 binury
########################
extends Node

const MOD_ID := "Toes.BetterLocalChat"

var default_config: Dictionary = {
	"infiniteChatRange": false,
	"silentCommandMessages": true,
	"messageSound": 2,
	"notifyOnMention": true,
	"soundOnMention": true,
	"notifyOnMessage": false,
	"soundOnMessage": false,
}

var config := {}

var should_warn_player_about_missing_mod := false

var message_sound_1 := preload("res://mods/Toes.BetterLocalChat/scenes/message_sound_1.tscn")
var message_sound_2 := preload("res://mods/Toes.BetterLocalChat/scenes/message_sound_2.tscn")
var message_sounds := {
	1: message_sound_1.instance(),
	2: message_sound_2.instance(),
}
var message_sound


onready var Chat = get_node("/root/ToesSocks/Chat")
onready var Players = get_node("/root/ToesSocks/Players")
onready var TackleBox = get_node_or_null("/root/TackleBox")


func _config_updated(id: String, __):
	if id != MOD_ID:
		return
	Chat.write("[color=purple]BetterLocalChat Settings Reloaded ✅[/color]")
	_init_config()
	set_msg_sound(config.messageSound)


func _init_config() -> void:
	var saved_config
	if TackleBox != null:
		saved_config = TackleBox.get_mod_config(MOD_ID)
	if not saved_config:
		print("[BetterLocalChat] EMPTY CONFIGURATION - USING DEFAULT AS FALLBACK")
		saved_config = default_config.duplicate()
	for key in default_config.keys():
		if not saved_config.has(key):
			saved_config[key] = default_config[key]
	config = saved_config
	_save_config()


func _save_config() -> void:
	TackleBox.set_mod_config(MOD_ID, config)


func _ready():
	Players.connect("ingame", self, "_on_ingame")
	Chat.connect("player_messaged", self, "_on_message")
	Chat.connect("player_emoted", self, "_on_emote")

	var llib = get_node_or_null("/root/LucysLib")
	if not llib:
		return
	llib.NetManager.add_network_processor("message", funcref(self, "process_packet_message"), 99)

	if TackleBox:
		TackleBox.connect("mod_config_updated", self, "_config_updated")
	else:
		should_warn_player_about_missing_mod = true
	_init_config()
	set_msg_sound(config.messageSound)


func set_msg_sound(choice):
	if message_sound != null and message_sound.get_parent():
		message_sound.get_parent().remove_child(message_sound)
	message_sound = message_sounds[int(choice)]
	add_child(message_sound)

func _on_ingame() -> void:
	if should_warn_player_about_missing_mod:
		Chat.write(
			(
				"Toes: Hey, %s, in order to properly use BetterLocalChat alongside LucysTools, you should install Tacklebox!"
				% Players.get_username(Players.local_player)
			)
		)
		should_warn_player_about_missing_mod = false

	var NEW_EDIT_BOX_CHAR_LIMIT = 480
	# This seems to be about the limit of vanilla chat box length
	# FWIW 20k is around ~ the actual network packet limit
	# This can be higher but it requires modding on the receipient end
	var text_edit_box = get_tree().get_root().find_node("LineEdit", true, false)
	if text_edit_box:
		# Should def not be null but :shrug: y'never know w WF and mods
		text_edit_box.max_length = NEW_EDIT_BOX_CHAR_LIMIT
	else:
		push_error("[BetterLocalChat] Couldn't find LineEdit node. Unable to increase message limit and giving up.")


func _notify_if_mentioned(message: String) -> bool:
	var username: String = Players.get_username()
	var matcher := RegEx.new()
	matcher.compile("\\b%s\\b" % username.to_lower())
	var result = matcher.search(message.to_lower())
	if result != null:
		_flash_window()
		return true
	return false


func _on_message(message: String, player: String, from_self: bool):
	if from_self:
		return
	if config.notifyOnMessage:
		_flash_window()
	if config.soundOnMessage:
		message_sound.play()
	elif config.notifyOnMention and _notify_if_mentioned(message):
		if config.soundOnMention:
			message_sound.play()


func _flash_window():
	if not OS.is_window_focused():
		OS.request_attention()

func _on_emote(message: String, player: String, from_self: bool):
	if from_self:
		return
	if _notify_if_mentioned(message):
		message_sound.play()


func process_packet_message(DATA, PACKET_SENDER, from_host) -> bool:
	var has_bb := true
	if not Network._validate_packet_information(
		DATA,
		["message", "color", "local", "position", "zone", "zone_owner", "bb_user", "bb_msg"],
		[TYPE_STRING, TYPE_STRING, TYPE_BOOL, TYPE_VECTOR3, TYPE_STRING, TYPE_INT, TYPE_STRING, TYPE_STRING]
	):
		has_bb = false
		if not Network._validate_packet_information(
			DATA,
			["message", "color", "local", "position", "zone", "zone_owner"],
			[TYPE_STRING, TYPE_STRING, TYPE_BOOL, TYPE_VECTOR3, TYPE_STRING, TYPE_INT]
		):
			return true

	if PlayerData.players_muted.has(PACKET_SENDER) or PlayerData.players_hidden.has(PACKET_SENDER):
		return false

	if not Network._message_cap(PACKET_SENDER):
		return false

	var user_id: int = PACKET_SENDER
	var user_color: String = DATA["color"].left(12).replace("[", "")
	var user_message: String = DATA["message"]

	var bb_user: String = ""
	var bb_msg: String = ""
	if has_bb:
		bb_user = DATA["bb_user"]
		bb_msg = DATA["bb_msg"]

	if DATA["local"]:
		var dist = DATA["position"].distance_to(Network.MESSAGE_ORIGIN)
		if DATA["zone"] == Network.MESSAGE_ZONE and DATA["zone_owner"] == PlayerData.player_saved_zone_owner:
			if dist < 25.0 or config.get("infiniteChatRange", false):
				receive_safe_message(user_id, user_color, "(local) " + user_message, false, bb_msg, bb_user)
	return false


func receive_safe_message(
	user_id: int, color: String, message: String, local: bool = false, bb_msg: String = "", bb_user: String = ""
):
	var llib = get_node_or_null("/root/LucysLib")
	var srv_msg: bool = user_id == Network.STEAM_ID or user_id == Steam.getLobbyOwner(Network.STEAM_LOBBY_ID)

	if OptionsMenu.chat_filter:
		message = SwearFilter._filter_string(message)
		bb_msg = SwearFilter._filter_string(bb_msg)

	var ALLOWED_TAG_TYPES = llib.BBCode.DEFAULT_ALLOWED_TYPES
	var parsed_msg = _rsm_construct(user_id, color, message, local, bb_msg, bb_user, srv_msg)
	var final_message = llib.BBCode.parsed_to_text(parsed_msg, ALLOWED_TAG_TYPES, 512)

	Network._update_chat(final_message, local)


func _rsm_construct(
	user_id: int, color: String, message: String, local: bool, bb_msg: String, bb_user: String, srv_msg: bool
):
	var llib = get_node_or_null("/root/LucysLib")
	var net_name: String = Network._get_username_from_id(user_id).replace("[", "").replace("]", "")
	var name = llib.BBCode.parse_bbcode_text(net_name)
	if bb_user != "":
		if not srv_msg:
			var user_parse = llib.BBCode.parse_bbcode_text(bb_user)
			llib.BBCode.clamp_alpha(user_parse, 0.7)
			if user_parse.get_stripped() == net_name:
				name = user_parse
		else:
			name = llib.BBCode.parse_bbcode_text(bb_user)

	var to_parse = bb_msg if bb_msg != "" else message
	if not "%u" in to_parse.left(32) and not srv_msg:
		to_parse = "%u " + to_parse
	var parsed_msg = llib.BBCode.parse_bbcode_text(to_parse)

	var real_color: Color = color
	if not srv_msg:
		real_color.a = max(real_color.a, 0.7)
	var color_node = llib.BBCode.tag_creator(llib.BBCode.TAG_TYPE.color, "")
	color_node.color = real_color
	color_node.inner = [name]

	llib.BBCode.replace_in_strings(parsed_msg, "%u", color_node)

	return parsed_msg
