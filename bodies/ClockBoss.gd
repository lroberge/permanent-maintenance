extends CombatBody

const quadrants = [Vector3(5, 0, -5), Vector3(-5, 0, -5), Vector3(-5, 0, 5), Vector3(5, 0, 5)]

const quadrants_forreal = [Vector3(1, 0, -1), Vector3(-1, 0, -1), Vector3(-1, 0, 1), Vector3(1, 0, 1)]

func _unhandled_input(event: InputEvent) -> void:
	pass


func spawn_new_aoe() -> void:
	AoeManager.create_aoe(
		AoEs.BasicAoEs.square,
		AoEs.damage_callback(10.0, self),
		Damage.get_random_opposing_combatant(self).position
	)

func quadrants_attack() -> void:
	var safe_quad = quadrants.pick_random()
	var quads_to_attack = quadrants.filter(func (q: Vector3): return q != safe_quad)
	for quad in quads_to_attack:
		AoeManager.create_aoe(
			AoEs.BasicAoEs.square,
			AoEs.damage_callback(10.0, self),
			quad, 3
		)

func split_quads(quads: Array[Vector3]) -> Array[Vector3]:
	return quads.map(func(quad: Vector3): return [quad * 7, quad * 3.5] as Array[Vector3]) \
		.reduce(func(acc, next): return acc + next, [] as Array[Vector3])

func grid_attack() -> void:
	var positive_lines = split_quads([quadrants_forreal[1], quadrants_forreal[3]]) + [Vector3(0,0,0)]
	var safe_positive_line = positive_lines.pick_random()
	positive_lines = positive_lines.filter(func (q: Vector3): return q != safe_positive_line)
	var negative_lines = split_quads([quadrants_forreal[0], quadrants_forreal[2]]) + [Vector3(0,0,0)]
	var safe_negative_line = negative_lines.pick_random()
	negative_lines = negative_lines.filter(func (q: Vector3): return q != safe_negative_line)
	for line in positive_lines:
		AoeManager.create_line_aoe(-45.0, AoEs.damage_callback(10.0, self), line)
	for line in negative_lines:
		AoeManager.create_line_aoe(45.0, AoEs.damage_callback(10.0, self), line)
