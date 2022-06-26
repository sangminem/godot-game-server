extends GameServerData
class_name GameServerMethods

onready var main = get_node("/root/Main")

remote func FetchAction(action_name, value_name, requester = null):
	var player_id = get_tree().get_rpc_sender_id()
	var return_value
	match action_name:
		"skill_damage":
			return_value = GetSkillDamage(value_name, player_id)
		"get_data":
			match value_name:
				"Player Stats":
					return_value = GetStats(player_id)
				_:
					return_value = ""
		_:
			return_value = ""
	rpc_id(player_id, "ReturnAction", action_name, value_name, return_value, requester)
	print("sending " + str(return_value) + " to player")


func GetSkillDamage(skill_name, player_id):
	var damage = skill_data[skill_name].Damage * 0.1 * GetStats(player_id).Intelligence
	return damage


func GetStats(player_id):
	return main.get_node(str(player_id)).player_stats


remote func SendNPCHit(enemy_id, damage):
	main.get_node("Map").NPCHit(enemy_id, damage)


remote func FetchServerTime(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)


remote func DetermineLatency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnLatency", client_time)


func FetchToken(player_id):
	rpc_id(player_id, "FetchToken")


remote func ReturnToken(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.Verify(player_id, token)


func ReturnTokenVerificationResults(player_id, result):
	rpc_id(player_id, "ReturnTokenVerificationResults", result)
	if result == true:
		rpc_id(0, "SpawnNewPlayer", player_id, Vector2(100, 100))


remote func ReceivePlayerState(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state
		

func SendWorldState(world_state):
	rpc_unreliable_id(0, "ReceiveWorldState", world_state)


remote func Attack(position, animation_vector, spawn_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(0, "ReceiveAttack", position, animation_vector, spawn_time, player_id)


func DespawnEnemy(enemy):
	rpc_id(0, "DespawnEnemy", enemy)
