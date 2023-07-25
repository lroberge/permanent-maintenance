extends CombatBody

const normalized_cardinals = [Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(-1, 0, 0)]
const normalized_quadrants = [Vector3(1, 0, -1), Vector3(-1, 0, -1), Vector3(-1, 0, 1), Vector3(1, 0, 1)]
const INT_MAX = 0x7FFFFFFF

const halfpast_attack = preload("res://attacks/compound/half_past.tscn")
const calendar_attack = preload("res://attacks/compound/calendar.tscn")
const urgencymatrix_attack = preload("res://attacks/compound/urgency_matrix.tscn")
const milleniumbug_attack = preload("res://attacks/compound/millenium_bug.tscn")

var attackorder: Array[PackedScene] = [halfpast_attack, urgencymatrix_attack, calendar_attack] #, milleniumbug_attack]
var nextattack = 0

func _unhandled_input(event: InputEvent) -> void:
	pass

func start_going():
	$AttackTimer.start()

func do_next_attack():
	var new_attack = attackorder[nextattack].instantiate() as CompoundAttack
	EncounterManager.active_encounter.add_child(new_attack)
	new_attack.fire(self)
	# print("spawned " + str(new_attack))
	nextattack += 1
	if nextattack >= attackorder.size():
		nextattack = 0

#func do_next_attack_old():
#	attackorder[nextattack].call()
#	nextattack += 1
#	if nextattack >= attackorder.size():
#		nextattack = 0
#	pass

func ATK_half_past():
	var center = normalized_cardinals.pick_random()
	AoeManager.create_aoe(AoeSettings.new("line", AoEs.damage_callback(10.0, self)).with_position(center * 5).with_rotation(90.0 * center.x).with_scale(2))

func ATK_urgency_matrix() -> void:
	var quads = offset_quadrants(5)
	var safe_quad = quads.pick_random()
	quads = quads.filter(func (q: Vector3): return q != safe_quad)
	for quad in quads:
		AoeManager.create_aoe(
			AoeSettings.new("square", AoEs.damage_callback(10.0, self))
			.with_position(quad)
			.with_scale(2)
			)

func ATK_calendar() -> void:
	var inner_lines = offset_quadrants(1.75)
	var safe_lines = [
		get_every_other(inner_lines, false).pick_random(),
		get_every_other(inner_lines, true).pick_random()
		]
	inner_lines = inner_lines.map(func(line: Vector3): return line if not safe_lines.any(func(safe_line: Vector3): return safe_line == line) else null)

	var line_centers = offset_quadrants(5.25) + inner_lines
	for idx in line_centers.size():
		var linepos = line_centers[idx]
		if linepos != null:
			# odds are negative, evens (and zeroes) are positive
			var sign = 1.0 if (idx % 2) == 0 else -1.0
			AoeManager.create_aoe(
				AoeSettings.new("line", AoEs.damage_callback(10.0, self))
				.with_position(linepos)
				.with_rotation(45.0 * sign)
				)

func get_every_other(arr: Array[Variant], offset: bool = false):
	return arr.slice(1 if offset else 0, INT_MAX, 2)

func offset_quadrants(factor: float):
	return normalized_quadrants.map(func(quad: Vector3): return (quad * factor as Vector3))

func split_quads(quads: Array[Vector3]) -> Array[Vector3]:
	return quads.map(func(quad: Vector3): return [quad * 5.25, quad * 1.75] as Array[Vector3]) \
		.reduce(func(acc, next): return acc + next, [] as Array[Vector3])

#func grid_attack() -> void:
#	var positive_lines = split_quads([normalized_quadrants[1], normalized_quadrants[3]])
#	var safe_positive_line = positive_lines.pick_random()
#	positive_lines = positive_lines.filter(func (q: Vector3): return q != safe_positive_line)
#	var negative_lines = split_quads([normalized_quadrants[0], normalized_quadrants[2]])
#	var safe_negative_line = negative_lines.pick_random()
#	negative_lines = negative_lines.filter(func (q: Vector3): return q != safe_negative_line)
#	for line in positive_lines:
#		AoeManager.create_line_aoe(-45.0, AoEs.damage_callback(10.0, self), line)
#	for line in negative_lines:
#		AoeManager.create_line_aoe(45.0, AoEs.damage_callback(10.0, self), line)
