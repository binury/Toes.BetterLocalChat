extends Node


func _init():
	pass
	var llib = get_node_or_null("/root/LucysLib")
	if not llib:
		print('*'.repeat(100))
		print("NO LUCY LIB ????")
		print('*'.repeat(100))
		return
	llib.NetManager.add_network_processor("message", funcref(self, "process_packet_message"), 99)


func _ready():
	var llib = get_node_or_null("/root/LucysLib")

	if not llib: return
	llib.NetManager.add_network_processor("message", funcref(self, "process_packet_message"), 99)


func process_packet_message(DATA, PACKET_SENDER, from_host) -> bool:
	print("BETTER LOCAL CHAT PROCESSING")
	var has_bb := true
	if not Network._validate_packet_information(DATA,
		["message", "color", "local", "position", "zone", "zone_owner", "bb_user", "bb_msg"],
		[TYPE_STRING, TYPE_STRING, TYPE_BOOL, TYPE_VECTOR3, TYPE_STRING, TYPE_INT, TYPE_STRING, TYPE_STRING]):
		has_bb = false
		if not Network._validate_packet_information(DATA,
			["message", "color", "local", "position", "zone", "zone_owner"],
			[TYPE_STRING, TYPE_STRING, TYPE_BOOL, TYPE_VECTOR3, TYPE_STRING, TYPE_INT]):
			return true

	if PlayerData.players_muted.has(PACKET_SENDER) or PlayerData.players_hidden.has(PACKET_SENDER):
		return false

	if not Network._message_cap(PACKET_SENDER): return false

	var user_id: int = PACKET_SENDER
	var user_color: String = DATA["color"].left(12).replace('[','')
	var user_message: String = DATA["message"]

	var bb_user: String = ""
	var bb_msg: String = ""
	if has_bb:
		bb_user = DATA["bb_user"]
		bb_msg = DATA["bb_msg"]

	if DATA["local"]:
		var dist = DATA["position"].distance_to(Network.MESSAGE_ORIGIN)
		if DATA["zone"] == Network.MESSAGE_ZONE and DATA["zone_owner"] == PlayerData.player_saved_zone_owner:
			if dist < 25.0:
				receive_safe_message(user_id, user_color, "(local) " + user_message, false, bb_msg, bb_user)
	return false

func receive_safe_message(user_id: int, color: String, message: String, local: bool = false,
		bb_msg: String = "", bb_user: String = ""):
	var llib = get_node_or_null("/root/LucysLib")
	var srv_msg: bool = user_id == Network.STEAM_ID or user_id == Steam.getLobbyOwner(Network.STEAM_LOBBY_ID)

	if OptionsMenu.chat_filter:
		message = SwearFilter._filter_string(message)
		bb_msg = SwearFilter._filter_string(bb_msg)

	var ALLOWED_TAG_TYPES = llib.BBCode.DEFAULT_ALLOWED_TYPES
	var parsed_msg = _rsm_construct(user_id, color, message, local, bb_msg, bb_user, srv_msg)
	var final_message = llib.BBCode.parsed_to_text(parsed_msg, ALLOWED_TAG_TYPES, 512)

	Network._update_chat(final_message, local)

func _rsm_construct(user_id: int, color: String, message: String, local: bool,
		bb_msg: String, bb_user: String, srv_msg: bool):
	var llib = get_node_or_null("/root/LucysLib")
	var net_name: String = Network._get_username_from_id(user_id).replace('[','').replace(']','')
	var name = llib.BBCode.parse_bbcode_text(net_name)
	if bb_user != "":
		if not srv_msg:
			var user_parse = llib.BBCode.parse_bbcode_text(bb_user)
			llib.clamp_alpha(user_parse, 0.7)
			if user_parse.get_stripped() == net_name:
				name = user_parse
		else:
			name = llib.BBCode.parse_bbcode_text(bb_user)

	var to_parse = bb_msg if bb_msg != "" else message
	if not "%u" in to_parse.left(32) and not srv_msg:
		to_parse = "%u " + to_parse
	var parsed_msg = llib.BBCode.parse_bbcode_text(to_parse)

	var real_color: Color = color
	if not srv_msg: real_color.a = max(real_color.a, 0.7)
	var color_node  = llib.BBCode.tag_creator(llib.BBCode.TAG_TYPE.color,"")
	color_node.color = real_color
	color_node.inner = [name]

	llib.BBCode.replace_in_strings(parsed_msg,"%u",color_node)

	return parsed_msg
