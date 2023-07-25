extends Node

# stands for global cooldown
# in case i ever come back to this project after forgetting everything about FFXIV somehow
const GCD_MAX = 3

var active_player: Player = null
var active_actions: Array[PlayerActionDefinition] = []
var active_actions_by_id = {}
var active_cooldowns = {}

var current_gcd = 0

func _init() -> void:
	print("actions synchronizer initialized")

func register_player(player: Player) -> void:
	active_player = player

func register_actionset(actions: Array[PlayerActionDefinition]) -> void:
	active_actions = actions
	for action in actions:
		active_actions_by_id[action.id] = action

func _process(delta: float) -> void:
	var actions_on_cooldown = active_cooldowns.keys()
	for action_on_cooldown in actions_on_cooldown:
		var new_cd = active_cooldowns.get(action_on_cooldown) - delta
		if new_cd <= 0:
			active_cooldowns.erase(action_on_cooldown)
		else:
			active_cooldowns[action_on_cooldown] = new_cd
	if current_gcd > 0:
		current_gcd -= delta
		if current_gcd <= 0:
			current_gcd = 0


func get_action_cooldown(action_id: StringName):
	return active_cooldowns.get(action_id, -1)

func get_global_cooldown_percent():
	return current_gcd / GCD_MAX


func fire_action(action_id: StringName):
	if current_gcd > 0 or active_cooldowns.get(action_id, 0) > 0:
		return false # fail
	var succeeded = active_player.call(action_id)
	if succeeded:
		current_gcd = GCD_MAX
		if active_actions_by_id[action_id].cooldown > 0:
			active_cooldowns[action_id] = active_actions_by_id[action_id].cooldown
	else:
		# play a sound for failed actions or sthn
		pass

func fire_action_indexed(idx: int):
	return fire_action(active_actions[idx].id)


func _unhandled_key_input(event: InputEvent) -> void:
	for idx in active_actions.size():
		if event.is_action_pressed("player_action" + str(idx + 1)):
			fire_action_indexed(idx)
